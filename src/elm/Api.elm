module Api exposing (decodeAwsData)

import Api.NetworkACLsResponse as NetworkACLsResponse exposing (NetworkACLsResponse)
import Api.RouteTablesResponse as RouteTablesResponse exposing (RouteTablesResponse)
import Dict exposing (Dict)
import IpAddress exposing (Ipv4Address)
import Json.Decode as Json
import Node exposing (Node)
import Vpc exposing (Vpc)
import Vpc.SecurityGroup as SecurityGroup exposing (SecurityGroup)
import Vpc.Subnet as Subnet exposing (Subnet)


decodeAwsData : Json.Value -> Result Json.Error (List Vpc)
decodeAwsData =
    Json.decodeValue awsDataDecoder >> Result.map buildVpcs


awsDataDecoder : Json.Decoder AwsData
awsDataDecoder =
    Json.map6 AwsData
        (Json.field "vpcsResponse" vpcsDecoder)
        (Json.field "subnetsResponse" subnetsDecoder)
        (Json.field "securityGroupsResponse" securityGroupsDecoder)
        (Json.field "instancesResponse" instancesDecoder)
        (Json.field "routeTablesResponse" RouteTablesResponse.decoder)
        (Json.field "networkACLsResponse" NetworkACLsResponse.decoder)


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


buildVpcs : AwsData -> List Vpc
buildVpcs ({ vpcs, subnets, securityGroups, instances, routeTables } as awsData) =
    buildNodes awsData
        |> buildSubnets subnets
        |> buildVpcs_ vpcs


buildVpcs_ : List VpcResponse -> Dict VpcId (List Subnet) -> List Vpc
buildVpcs_ vpcs subnetsByVpc =
    List.foldl (collectVpc subnetsByVpc) [] vpcs


collectVpc : Dict String (List Subnet) -> VpcResponse -> List Vpc -> List Vpc
collectVpc subnetsByVpc vpc vpcs =
    Vpc.build vpc.id (Dict.get vpc.id subnetsByVpc |> Maybe.withDefault []) :: vpcs


buildNodes : AwsData -> Dict SubnetId (List Node)
buildNodes awsData =
    collectInstances awsData


collectInstances : AwsData -> Dict SubnetId (List Node)
collectInstances ({ instances } as awsData) =
    List.foldl (collectInstance awsData) Dict.empty instances


collectInstance : AwsData -> InstanceResponse -> Dict SubnetId (List Node) -> Dict SubnetId (List Node)
collectInstance { securityGroups, routeTables, networkACLs } instance nodesBySubnet =
    let
        instance_ =
            Node.buildEc2
                { id = instance.id
                , securityGroups = List.filter (\group -> List.member (SecurityGroup.idAsString group) instance.securityGroups) securityGroups
                , privateIp = instance.privateIp
                , routeTable = RouteTablesResponse.find instance.vpcId instance.subnetId routeTables
                , publicIp = instance.publicIp
                , networkACL = NetworkACLsResponse.find instance.subnetId networkACLs
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
-- TODO: when associating nodes to a vpc and route tables/networkACLs to nodes, we should key the Dict using <vpc-subnet> to avoid issues when the same subnetId is used across different VPCs. I think this is unlikely in the real world, but it's better to completely avoid it.
