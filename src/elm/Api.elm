module Api exposing (loadAllTheThings)

import AwsFixtures.Json
import Cidr exposing (Cidr)
import Dict exposing (Dict)
import IpAddress exposing (Ipv4Address)
import Json.Decode as Json
import Node exposing (Node)
import Protocol
import Task
import Vpc exposing (Vpc)
import Vpc.SecurityGroup as SecurityGroup exposing (SecurityGroup)
import Vpc.Subnet as Subnet exposing (Subnet)


loadAllTheThings : (Result String (List Vpc) -> msg) -> Cmd msg
loadAllTheThings toMsg =
    decodeVpcs
        |> Result.andThen decodeSubnets
        |> Result.andThen decodeSecurityGroups
        |> Result.andThen decodeInstances
        |> Result.map buildVpcs
        |> Result.map (Task.succeed >> Task.attempt toMsg)
        |> Result.withDefault (Task.fail "something went wrong with the zipping" |> Task.attempt toMsg)


decodeVpcs : Result Json.Error VpcsResponse
decodeVpcs =
    Json.decodeString (Json.field "Vpcs" vpcsDecoder) AwsFixtures.Json.vpcs


vpcsDecoder : Json.Decoder VpcsResponse
vpcsDecoder =
    Json.list (Json.map VpcResponse (Json.field "VpcId" Json.string))


decodeSubnets : VpcsResponse -> Result Json.Error { vpcs : VpcsResponse, subnets : List SubnetResponse }
decodeSubnets vpcs =
    Json.decodeString (Json.field "Subnets" subnetsDecoder) AwsFixtures.Json.subnets
        |> Result.andThen
            (\subs ->
                Ok
                    { vpcs = vpcs
                    , subnets = subs
                    }
            )


subnetsDecoder : Json.Decoder (List SubnetResponse)
subnetsDecoder =
    Json.list
        (Json.map2 SubnetResponse
            (Json.field "SubnetId" Json.string)
            (Json.field "VpcId" Json.string)
        )


decodeSecurityGroups : { vpcs : b, subnets : c } -> Result Json.Error { vpcs : b, subnets : c, securityGroups : List SecurityGroup }
decodeSecurityGroups { vpcs, subnets } =
    Json.decodeString (Json.field "SecurityGroups" securityGroupsDecoder) AwsFixtures.Json.securityGroups
        |> Result.andThen
            (\secGroups ->
                Ok
                    { vpcs = vpcs
                    , subnets = subnets
                    , securityGroups = secGroups
                    }
            )


securityGroupsDecoder : Json.Decoder (List SecurityGroup)
securityGroupsDecoder =
    Json.list
        (Json.map3 SecurityGroup.build
            (Json.field "GroupId" Json.string)
            (Json.field "IpPermissions" rulesDecoder)
            (Json.field "IpPermissionsEgress" rulesDecoder)
        )


rulesDecoder : Json.Decoder (List SecurityGroup.Rule_)
rulesDecoder =
    Json.list
        (Json.map4 SecurityGroup.Rule_
            (Json.field "IpProtocol" protocolDecoder)
            fromPortDecoder
            toPortDecoder
            (Json.field "IpRanges" (Json.list cidrDecoder))
        )


fromPortDecoder : Json.Decoder Int
fromPortDecoder =
    Json.oneOf
        [ Json.field "FromPort" Json.int
        , Json.succeed 0
        ]


toPortDecoder : Json.Decoder Int
toPortDecoder =
    Json.oneOf
        [ Json.field "ToPort" Json.int
        , Json.succeed 65535
        ]


protocolDecoder : Json.Decoder Protocol.Protocol
protocolDecoder =
    Json.string
        |> Json.andThen
            (\protocol ->
                case protocol of
                    "tcp" ->
                        Json.succeed Protocol.Tcp

                    "-1" ->
                        Json.succeed Protocol.All

                    _ ->
                        Json.fail ("Unrecognised ip protocol: " ++ protocol)
            )


cidrDecoder : Json.Decoder Cidr
cidrDecoder =
    Json.field "CidrIp" Json.string
        |> Json.andThen
            (Cidr.fromString
                >> Maybe.map Json.succeed
                >> Maybe.withDefault (Json.fail "could not parse cidr")
            )


decodeInstances :
    { vpcs : VpcsResponse
    , subnets : SubnetsResponse
    , securityGroups : List SecurityGroup
    }
    -> Result Json.Error AllTheData
decodeInstances { vpcs, subnets, securityGroups } =
    Json.decodeString
        (Json.field "Reservations" (Json.list (Json.field "Instances" (Json.list instancesDecoder)))
            |> Json.map List.concat
        )
        AwsFixtures.Json.instances
        |> Result.andThen
            (\instances ->
                Ok
                    { vpcs = vpcs
                    , subnets = subnets
                    , securityGroups = securityGroups
                    , instances = instances
                    }
            )


instancesDecoder : Json.Decoder InstanceResponse
instancesDecoder =
    Json.map4 InstanceResponse
        (Json.field "InstanceId" Json.string)
        (Json.field "SubnetId" Json.string)
        (Json.field "PrivateIpAddress" decodeIpv4)
        (Json.field "SecurityGroups" (Json.list (Json.field "GroupId" Json.string)))


decodeIpv4 : Json.Decoder Ipv4Address
decodeIpv4 =
    Json.string
        |> Json.andThen
            (IpAddress.v4FromString
                >> Maybe.map Json.succeed
                >> Maybe.withDefault (Json.fail "could not parse ip")
            )


type alias AllTheData =
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


type alias SecurityGroupsResponse =
    List {}


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


buildVpcs : AllTheData -> List Vpc
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


buildSecurityGroups : SecurityGroupsResponse -> List SecurityGroup
buildSecurityGroups securityGroups =
    []


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
