module Api exposing (decodeAwsData)

import Api.RouteTablesResponse as RouteTablesResponse exposing (RouteTablesResponse)
import Dict exposing (Dict)
import IpAddress exposing (Ipv4Address)
import Json.Decode as Json
import Node exposing (Node)
import Vpc exposing (Vpc)
import Vpc.RouteTable as RouteTable exposing (RouteTable)
import Vpc.SecurityGroup as SecurityGroup exposing (SecurityGroup)
import Vpc.Subnet as Subnet exposing (Subnet)


decodeAwsData : Json.Value -> Result Json.Error (List Vpc)
decodeAwsData =
    Json.decodeValue awsDataDecoder >> Result.map buildVpcs


awsDataDecoder : Json.Decoder AwsData
awsDataDecoder =
    Json.map5 AwsData
        (Json.field "vpcsResponse" vpcsDecoder)
        (Json.field "subnetsResponse" subnetsDecoder)
        (Json.field "securityGroupsResponse" securityGroupsDecoder)
        (Json.field "instancesResponse" instancesDecoder)
        (Json.field "routeTablesResponse" RouteTablesResponse.decoder)


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
    Json.map5 InstanceResponse
        (Json.field "InstanceId" Json.string)
        (Json.field "SubnetId" Json.string)
        (Json.field "PrivateIpAddress" IpAddress.v4Decoder)
        (Json.field "SecurityGroups" (Json.list (Json.field "GroupId" Json.string)))
        (Json.field "VpcId" Json.string)


type alias AwsData =
    { vpcs : VpcsResponse
    , subnets : SubnetsResponse
    , securityGroups : List SecurityGroup
    , instances : InstancesResponse
    , routeTables : RouteTablesResponse
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
    , securityGroups : List String
    , vpcId : VpcId
    }


type alias SubnetsResponse =
    List SubnetResponse


type alias SubnetResponse =
    { id : String
    , vpcId : String
    }


findRouteTable : VpcId -> SubnetId -> RouteTablesResponse -> RouteTable
findRouteTable vpcId subnetId tablesResponse =
    findExplicitAssociation subnetId tablesResponse
        |> Maybe.withDefault
            (findImplicitAssociation vpcId tablesResponse
                -- TODO: rather than default to something wrong, change  buildVpcs to support failure with a Result type
                |> Maybe.withDefault (RouteTable.build [])
            )


findExplicitAssociation : SubnetId -> RouteTablesResponse -> Maybe RouteTable
findExplicitAssociation subnetId { explicit } =
    List.filter (appliesTo subnetId) explicit
        |> List.head
        |> Maybe.map Tuple.second


appliesTo : SubnetId -> ( List SubnetId, b ) -> Bool
appliesTo subnetId ( subnets, _ ) =
    List.member subnetId subnets


findImplicitAssociation : VpcId -> RouteTablesResponse -> Maybe RouteTable
findImplicitAssociation vpcId { implicit } =
    List.filter (Tuple.first >> (==) vpcId) implicit
        |> List.head
        |> Maybe.map Tuple.second


type alias SubnetId =
    String


type alias VpcId =
    String


buildVpcs : AwsData -> List Vpc
buildVpcs { vpcs, subnets, securityGroups, instances, routeTables } =
    buildNodes instances securityGroups routeTables
        |> buildSubnets subnets
        |> buildVpcs_ vpcs


buildVpcs_ : List VpcResponse -> Dict VpcId (List Subnet) -> List Vpc
buildVpcs_ vpcs subnetsByVpc =
    List.foldl (collectVpc subnetsByVpc) [] vpcs


collectVpc : Dict String (List Subnet) -> VpcResponse -> List Vpc -> List Vpc
collectVpc subnetsByVpc vpc vpcs =
    Vpc.build vpc.id (Dict.get vpc.id subnetsByVpc |> Maybe.withDefault []) :: vpcs


buildNodes : InstancesResponse -> List SecurityGroup -> RouteTablesResponse -> Dict SubnetId (List Node)
buildNodes instances securityGroups routeTables =
    collectInstances securityGroups instances routeTables


collectInstances : List SecurityGroup -> List InstanceResponse -> RouteTablesResponse -> Dict SubnetId (List Node)
collectInstances securityGroups instances routeTables =
    List.foldl (collectInstance securityGroups routeTables) Dict.empty instances


collectInstance : List SecurityGroup -> RouteTablesResponse -> InstanceResponse -> Dict SubnetId (List Node) -> Dict SubnetId (List Node)
collectInstance securityGroups routeTables instance nodesBySubnet =
    let
        instance_ =
            Node.buildEc2
                { id = instance.id
                , securityGroups = List.filter (\group -> List.member (SecurityGroup.idAsString group) instance.securityGroups) securityGroups
                , privateIp = instance.privateIp
                , routeTable = findRouteTable instance.vpcId instance.subnetId routeTables
                }

        addInstance nodes =
            nodes
                |> Maybe.map ((::) instance_ >> Just)
                |> Maybe.withDefault (Just [ instance_ ])
    in
    Dict.update instance.subnetId addInstance nodesBySubnet


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
-- TODO: this instance decoder currently fails when you have a terminated instance, as it will not have a subnetId when terminated
-- TODO: when associating nodes to a vpc and route tables to nodes, we should key the Dict using <vpc-subnet> to avoid issues when the same subnetId is used across different VPCs
