module Api exposing (decodeAwsData)

import Api.InstancesResponse as InstancesResponse exposing (InstanceResponse, InstancesResponse)
import Api.NetworkACLsResponse as NetworkACLsResponse exposing (NetworkACLsResponse)
import Api.NetworkInterfacesResponse as NetworkInterfacesResponse exposing (NetworkInterfacesResponse)
import Api.RdsResponse as RdsResponse exposing (RdsResponse, RdsesResponse)
import Api.RouteTablesResponse as RouteTablesResponse exposing (RouteTablesResponse)
import Dict exposing (Dict)
import Json.Decode as Json
import Node exposing (Node)
import Utils.Dict as Dict
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
        (Json.field "instancesResponse" InstancesResponse.decoder)
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

        instance_ =
            Result.map
                (\rt ->
                    Node.buildEc2
                        { id = instance.id
                        , securityGroups = findSecurityGroups instance.securityGroups securityGroups
                        , privateIp = instance.privateIp
                        , routeTable = rt
                        , publicIp = instance.publicIp
                        , networkACL = NetworkACLsResponse.find instance.subnetId networkACLs
                        }
                )
                routeTable
    in
    Result.map2
        (Dict.updateList instance.subnetId)
        instance_
        nodesBySubnet


collectDatabases : AwsData -> Result String (Dict String (List Node)) -> Result String (Dict String (List Node))
collectDatabases awsData otherNodes =
    List.foldl (collectDatabase awsData) otherNodes awsData.databases


collectDatabase : AwsData -> RdsResponse -> Result String (Dict String (List Node)) -> Result String (Dict String (List Node))
collectDatabase { securityGroups, routeTables, networkACLs, networkInterfaces } database nodesBySubnet =
    let
        networkInfo =
            NetworkInterfacesResponse.findRdsInfo database networkInterfaces

        routeTable =
            Result.andThen
                (\info -> RouteTablesResponse.find database.vpcId info.subnetId routeTables)
                networkInfo

        instance_ =
            Result.map2
                (\rt ni ->
                    Node.buildRds
                        { id = database.id
                        , securityGroups = findSecurityGroups database.securityGroups securityGroups
                        , privateIp = ni.ip
                        , routeTable = rt
                        , isPubliclyAccessible = database.isPubliclyAccessible
                        , networkACL = NetworkACLsResponse.find ni.subnetId networkACLs
                        }
                )
                routeTable
                networkInfo
    in
    Result.map3
        (\ni -> Dict.updateList ni.subnetId)
        networkInfo
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
    in
    Dict.updateList subnetResponse.vpcId subnet subnetsByVpc


findSecurityGroups : List String -> List SecurityGroup -> List SecurityGroup
findSecurityGroups groupIds securityGroups =
    List.filter (\group -> List.member (SecurityGroup.idAsString group) groupIds) securityGroups



-- TODO: the instance decoder currently fails when you have a terminated instance, as it will not have a subnetId when terminated - we should just filter those out instead
-- TODO: when associating nodes to a vpc and route tables/networkACLs to nodes, we should key the Dict using <vpc-subnet> to avoid issues when the same subnetId is used across different VPCs. I think this is unlikely in the real world, but it's better to completely avoid it.
