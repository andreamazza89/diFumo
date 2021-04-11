module Api exposing (decodeAwsData)

import Api.NetworkACLsResponse as NetworkACLsResponse exposing (NetworkACLsResponse)
import Api.NetworkInterfacesResponse as NetworkInterfacesResponse exposing (NetworkInterfacesResponse)
import Api.RdsResponse as RdsResponse exposing (RdsResponse, RdsesResponse)
import Api.RouteTablesResponse as RouteTablesResponse exposing (RouteTablesResponse)
import Dict exposing (Dict)
import IpAddress exposing (Ipv4Address)
import Json.Decode as Json
import Node exposing (Node)
import Vpc exposing (Vpc)
import Vpc.SecurityGroup as SecurityGroup exposing (SecurityGroup)
import Vpc.Subnet as Subnet exposing (Subnet)


decodeAwsData : Json.Value -> Result String (List Vpc)
decodeAwsData =
    Json.decodeValue awsDataDecoder
        >> Result.mapError Json.errorToString
        >> Result.andThen buildVpcs


awsDataDecoder : Json.Decoder AwsData
awsDataDecoder =
    Json.map8 AwsData
        (Json.field "vpcsResponse" vpcsDecoder)
        (Json.field "subnetsResponse" subnetsDecoder)
        (Json.field "securityGroupsResponse" securityGroupsDecoder)
        (Json.field "instancesResponse" instancesDecoder)
        (Json.field "routeTablesResponse" RouteTablesResponse.decoder)
        (Json.field "networkACLsResponse" NetworkACLsResponse.decoder)
        (Json.field "networkInterfacesResponse" NetworkInterfacesResponse.decoder)
        (Json.field "dbInstancesResponse" RdsResponse.decoder)


vpcsDecoder : Json.Decoder VpcsResponse
vpcsDecoder =
    Json.list vpcDecoder


vpcDecoder : Json.Decoder VpcResponse
vpcDecoder =
    Json.map VpcResponse (Json.field "VpcId" Json.string)


subnetsDecoder : Json.Decoder (List SubnetResponse)
subnetsDecoder =
    Json.list subnetDecoder


subnetDecoder : Json.Decoder SubnetResponse
subnetDecoder =
    Json.map2 SubnetResponse
        (Json.field "SubnetId" Json.string)
        (Json.field "VpcId" Json.string)


securityGroupsDecoder : Json.Decoder (List SecurityGroup)
securityGroupsDecoder =
    Json.list SecurityGroup.decoder


instancesDecoder : Json.Decoder (List InstanceResponse)
instancesDecoder =
    Json.list (Json.field "Instances" (Json.list instanceDecoder))
        |> Json.map List.concat


instanceDecoder : Json.Decoder InstanceResponse
instanceDecoder =
    Json.map6 InstanceResponse
        (Json.field "InstanceId" Json.string)
        (Json.field "SubnetId" Json.string)
        (Json.field "PrivateIpAddress" IpAddress.v4Decoder)
        publicIpDecoder
        (Json.field "SecurityGroups" (Json.list (Json.field "GroupId" Json.string)))
        (Json.field "VpcId" Json.string)


publicIpDecoder : Json.Decoder (Maybe Ipv4Address)
publicIpDecoder =
    Json.oneOf
        [ Json.field "PublicIpAddress" IpAddress.v4Decoder |> Json.map Just
        , Json.succeed Nothing
        ]


type alias AwsData =
    { vpcs : VpcsResponse
    , subnets : SubnetsResponse
    , securityGroups : List SecurityGroup
    , instances : InstancesResponse
    , routeTables : RouteTablesResponse
    , networkACLs : NetworkACLsResponse
    , networkInterfaces : NetworkInterfacesResponse
    , databases : RdsesResponse
    }


type alias VpcsResponse =
    List VpcResponse


type alias VpcResponse =
    { id : VpcId }


type alias InstancesResponse =
    List InstanceResponse


type alias InstanceResponse =
    { id : String
    , subnetId : String
    , privateIp : Ipv4Address
    , publicIp : Maybe Ipv4Address
    , securityGroups : List String
    , vpcId : VpcId
    }


type alias SubnetsResponse =
    List SubnetResponse


type alias SubnetResponse =
    { id : String
    , vpcId : String
    }


type alias SubnetId =
    String


type alias VpcId =
    String



-- Zipping up the api responses


buildVpcs : AwsData -> Result String (List Vpc)
buildVpcs ({ vpcs, subnets, securityGroups, instances, routeTables } as awsData) =
    buildNodes awsData
        |> Result.map (buildSubnets subnets)
        |> Result.map (buildVpcs_ vpcs)


buildVpcs_ : List VpcResponse -> Dict VpcId (List Subnet) -> List Vpc
buildVpcs_ vpcs subnetsByVpc =
    List.foldl (collectVpc subnetsByVpc) [] vpcs


collectVpc : Dict String (List Subnet) -> VpcResponse -> List Vpc -> List Vpc
collectVpc subnetsByVpc vpc vpcs =
    Vpc.build vpc.id (Dict.get vpc.id subnetsByVpc |> Maybe.withDefault []) :: vpcs


buildNodes : AwsData -> Result String (Dict SubnetId (List Node))
buildNodes awsData =
    collectInstances awsData
        |> collectDatabases awsData


collectInstances : AwsData -> Result String (Dict SubnetId (List Node))
collectInstances ({ instances } as awsData) =
    List.foldl (collectInstance awsData) (Result.Ok Dict.empty) instances


collectInstance : AwsData -> InstanceResponse -> Result String (Dict String (List Node)) -> Result String (Dict String (List Node))
collectInstance { securityGroups, routeTables, networkACLs } instance nodesBySubnet =
    let
        routeTable =
            RouteTablesResponse.find instance.vpcId instance.subnetId routeTables
                |> Result.fromMaybe ("Could not find route table for ec2 " ++ instance.id)

        instance_ =
            routeTable
                |> Result.map
                    (\rt ->
                        Node.buildEc2
                            { id = instance.id
                            , securityGroups = List.filter (\group -> List.member (SecurityGroup.idAsString group) instance.securityGroups) securityGroups
                            , privateIp = instance.privateIp
                            , routeTable = rt
                            , publicIp = instance.publicIp
                            , networkACL = NetworkACLsResponse.find instance.subnetId networkACLs
                            }
                    )

        addInstance inst nodes =
            nodes
                |> Maybe.map ((::) inst >> Just)
                |> Maybe.withDefault (Just [ inst ])
    in
    Result.map2
        (\inst nodes ->
            Dict.update instance.subnetId (addInstance inst) nodes
        )
        instance_
        nodesBySubnet


collectDatabases : AwsData -> Result String (Dict String (List Node)) -> Result String (Dict String (List Node))
collectDatabases awsData otherNodes =
    List.foldl (collectDatabase awsData) otherNodes awsData.databases


collectDatabase : AwsData -> RdsResponse -> Result String (Dict String (List Node)) -> Result String (Dict String (List Node))
collectDatabase { securityGroups, routeTables, networkACLs, networkInterfaces } database nodesBySubnet =
    let
        networkInfo =
            ------------ Time has come to switch to a Result when zipping rather than defaulting to something wrong like below
            NetworkInterfacesResponse.findRdsInfo database networkInterfaces
                |> Maybe.withDefault
                    { securityGroups = []
                    , vpcId = "asdf"
                    , ip = IpAddress.madeUpV4
                    , subnetId = "FIX THIS"
                    , instanceOwnerId = "hi"
                    }

        routeTable =
            RouteTablesResponse.find database.vpcId networkInfo.subnetId routeTables
                |> Result.fromMaybe ("Could not find route table for database " ++ database.id)

        instance_ : Result String Node
        instance_ =
            routeTable
                |> Result.map
                    (\rt ->
                        Node.buildRds
                            { id = database.id
                            , securityGroups = List.filter (\group -> List.member (SecurityGroup.idAsString group) database.securityGroups) securityGroups
                            , privateIp = networkInfo.ip
                            , routeTable = rt
                            , isPubliclyAccessible = database.isPubliclyAccessible
                            , networkACL = NetworkACLsResponse.find networkInfo.subnetId networkACLs
                            }
                    )

        addInstance : Node -> Maybe (List Node) -> Maybe (List Node)
        addInstance node nodes =
            nodes
                |> Maybe.map ((::) node >> Just)
                |> Maybe.withDefault (Just [ node ])
    in
    Result.map2
        (\db nodes ->
            Dict.update networkInfo.subnetId (addInstance db) nodes
        )
        instance_
        nodesBySubnet


buildSubnets : SubnetsResponse -> Dict SubnetId (List Node) -> Dict VpcId (List Subnet)
buildSubnets subnets nodesBySubnet =
    List.foldl (collectSubnet nodesBySubnet) Dict.empty subnets


collectSubnet : Dict String (List Node) -> SubnetResponse -> Dict VpcId (List Subnet) -> Dict VpcId (List Subnet)
collectSubnet nodesBySubnet subnetResponse subnetsByVpc =
    let
        nodes =
            Dict.get subnetResponse.id nodesBySubnet
                |> Maybe.withDefault []

        subnet =
            Subnet.build subnetResponse.id nodes

        addSubnet subs =
            subs
                |> Maybe.map ((::) subnet >> Just)
                |> Maybe.withDefault (Just [ subnet ])
    in
    Dict.update subnetResponse.vpcId addSubnet subnetsByVpc



-- TODO: write a Dict.updateList and Dict.getOrEmptyList utility
-- TODO: the instance decoder currently fails when you have a terminated instance, as it will not have a subnetId when terminated - we should just filter those out instead
-- TODO: when associating nodes to a vpc and route tables/networkACLs to nodes, we should key the Dict using <vpc-subnet> to avoid issues when the same subnetId is used across different VPCs. I think this is unlikely in the real world, but it's better to completely avoid it.
