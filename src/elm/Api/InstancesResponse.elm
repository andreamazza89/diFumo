module Api.InstancesResponse exposing (..)

import IpAddress exposing (Ipv4Address)
import Json.Decode as Json
import Tag exposing (Tag)


type alias InstancesResponse =
    List InstanceResponse


type alias InstanceResponse =
    { id : String
    , subnetId : String
    , privateIp : Ipv4Address
    , publicIp : Maybe Ipv4Address
    , securityGroups : List String
    , vpcId : VpcId
    , tags : List Tag
    }


type alias VpcId =
    String


decoder : Json.Decoder InstancesResponse
decoder =
    Json.list (Json.field "Instances" (Json.list instanceDecoder))
        |> Json.map List.concat


instanceDecoder : Json.Decoder InstanceResponse
instanceDecoder =
    Json.map7 InstanceResponse
        (Json.field "InstanceId" Json.string)
        (Json.field "SubnetId" Json.string)
        (Json.field "PrivateIpAddress" IpAddress.v4Decoder)
        publicIpDecoder
        (Json.field "SecurityGroups" (Json.list (Json.field "GroupId" Json.string)))
        (Json.field "VpcId" Json.string)
        Tag.decoder


publicIpDecoder : Json.Decoder (Maybe Ipv4Address)
publicIpDecoder =
    Json.oneOf
        [ Json.field "PublicIpAddress" IpAddress.v4Decoder |> Json.map Just
        , Json.succeed Nothing
        ]
