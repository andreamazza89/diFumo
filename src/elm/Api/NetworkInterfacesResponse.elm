module Api.NetworkInterfacesResponse exposing
    ( NetworkInterfacesResponse
    , decoder
    , findRdsInfo
    )

import IpAddress exposing (Ipv4Address)
import Json.Decode as Json


type alias NetworkInterfacesResponse =
    List NetworkInterfaceResponse


type alias NetworkInterfaceResponse =
    { vpcId : String
    , subnetId : String
    , securityGroups : List String
    , ip : Ipv4Address
    , instanceOwnerId : String
    }


type alias NetworkInfo =
    { ip : Ipv4Address
    , subnetId : String
    }



-- Explain here how this is a best guess, but it should be ok in most scenarios


findRdsInfo :
    { a
        | vpcId : String
        , securityGroups : List String
        , subnetIds : List String
    }
    -> NetworkInterfacesResponse
    -> Maybe NetworkInterfaceResponse
findRdsInfo { vpcId, subnetIds, securityGroups } =
    List.filter (.vpcId >> (==) vpcId)
        >> List.filter (.subnetId >> (\id -> List.member id subnetIds))
        >> List.filter (.securityGroups >> (==) securityGroups)
        >> List.filter (.instanceOwnerId >> (==) "amazon-rds")
        >> List.head


decoder : Json.Decoder NetworkInterfacesResponse
decoder =
    Json.list decoder_


decoder_ : Json.Decoder NetworkInterfaceResponse
decoder_ =
    Json.map5 NetworkInterfaceResponse
        (Json.field "VpcId" Json.string)
        (Json.field "SubnetId" Json.string)
        (Json.field "Groups" (Json.list (Json.field "GroupId" Json.string)))
        (Json.field "PrivateIpAddress" IpAddress.v4Decoder)
        (Json.at [ "Attachment", "InstanceOwnerId" ] Json.string)