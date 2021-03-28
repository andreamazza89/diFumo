module Api exposing (decodeAwsData)

import Cidr exposing (Cidr)
import Dict exposing (Dict)
import IpAddress exposing (Ipv4Address)
import Json.Decode as Json
import Node exposing (Node)
import Port
import Protocol exposing (Protocol)
import Vpc exposing (Vpc)
import Vpc.RouteTable as RouteTable
import Vpc.SecurityGroup as SecurityGroup exposing (SecurityGroup)
import Vpc.Subnet as Subnet exposing (Subnet)


decodeAwsData : Json.Value -> Result Json.Error (List Vpc)
decodeAwsData =
    Json.decodeValue awsDataDecoder >> Result.map buildVpcs


awsDataDecoder : Json.Decoder AwsData
awsDataDecoder =
    Json.map4 AwsData
        (Json.field "vpcsResponse" vpcsDecoder)
        (Json.field "subnetsResponse" subnetsDecoder)
        (Json.field "securityGroupsResponse" securityGroupsDecoder)
        (Json.field "instancesResponse" instancesDecoder)


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
    Json.list securityGroupDecoder


securityGroupDecoder : Json.Decoder SecurityGroup
securityGroupDecoder =
    Json.map3 SecurityGroup.build
        (Json.field "GroupId" Json.string)
        (Json.field "IpPermissions" rulesDecoder)
        (Json.field "IpPermissionsEgress" rulesDecoder)


rulesDecoder : Json.Decoder (List SecurityGroup.Rule_)
rulesDecoder =
    Json.list
        (Json.map4 SecurityGroup.Rule_
            protocolDecoder
            fromPortDecoder
            toPortDecoder
            cidrsDecoder
        )


protocolDecoder : Json.Decoder Protocol
protocolDecoder =
    Json.field "IpProtocol" Protocol.decoder


fromPortDecoder : Json.Decoder Int
fromPortDecoder =
    Json.oneOf
        [ Json.field "FromPort" Port.decoder
        , Json.succeed Port.first -- when FromPort is missing, that means all ports (at least as far as we've seen)
        ]


toPortDecoder : Json.Decoder Int
toPortDecoder =
    Json.oneOf
        [ Json.field "ToPort" Port.decoder
        , Json.succeed Port.last -- when ToPort is missing, that means all ports (at least as far as we've seen)
        ]


cidrsDecoder : Json.Decoder (List Cidr)
cidrsDecoder =
    Json.field "IpRanges" (Json.list cidrDecoder)


cidrDecoder : Json.Decoder Cidr
cidrDecoder =
    Json.field "CidrIp" Cidr.decoder


instancesDecoder : Json.Decoder (List InstanceResponse)
instancesDecoder =
    Json.list (Json.field "Instances" (Json.list instanceDecoder))
        |> Json.map List.concat


instanceDecoder : Json.Decoder InstanceResponse
instanceDecoder =
    Json.map4 InstanceResponse
        (Json.field "InstanceId" Json.string)
        (Json.field "SubnetId" Json.string)
        (Json.field "PrivateIpAddress" IpAddress.v4Decoder)
        (Json.field "SecurityGroups" (Json.list (Json.field "GroupId" Json.string)))


type alias AwsData =
    { vpcs : VpcsResponse
    , subnets : SubnetsResponse
    , securityGroups : List SecurityGroup
    , instances : InstancesResponse
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


buildVpcs : AwsData -> List Vpc
buildVpcs { vpcs, subnets, securityGroups, instances } =
    buildNodes instances securityGroups
        |> buildSubnets subnets
        |> buildVpcs_ vpcs


buildVpcs_ : List VpcResponse -> Dict VpcId (List Subnet) -> List Vpc
buildVpcs_ vpcs subnetsByVpc =
    List.foldl (collectVpc subnetsByVpc) [] vpcs


collectVpc : Dict String (List Subnet) -> VpcResponse -> List Vpc -> List Vpc
collectVpc subnetsByVpc vpc vpcs =
    Vpc.build vpc.id (Dict.get vpc.id subnetsByVpc |> Maybe.withDefault []) :: vpcs


buildNodes : InstancesResponse -> List SecurityGroup -> Dict SubnetId (List Node)
buildNodes instances securityGroups =
    collectInstances securityGroups instances


collectInstances : List SecurityGroup -> List InstanceResponse -> Dict SubnetId (List Node)
collectInstances securityGroups instances =
    List.foldl (collectInstance securityGroups) Dict.empty instances


collectInstance : List SecurityGroup -> InstanceResponse -> Dict SubnetId (List Node) -> Dict SubnetId (List Node)
collectInstance securityGroups instance nodesBySubnet =
    let
        instance_ =
            Node.buildEc2
                { id = instance.id
                , securityGroups = List.filter (\group -> List.member (SecurityGroup.idAsString group) instance.securityGroups) securityGroups
                , privateIp = instance.privateIp
                , routeTable = RouteTable.build [] -- TODO use the actual one rather than stub
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
