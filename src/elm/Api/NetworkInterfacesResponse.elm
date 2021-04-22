module Api.NetworkInterfacesResponse exposing
    ( NetworkInterfacesResponse
    , decoder
    , findForAddress
    , findLoadBalancerInfo
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
    -> Result String NetworkInterfaceResponse
findRdsInfo { vpcId, subnetIds, securityGroups } =
    List.filter (.vpcId >> (==) vpcId)
        >> List.filter (.subnetId >> (\id -> List.member id subnetIds))
        >> List.filter (.securityGroups >> (==) securityGroups)
        >> List.filter (.instanceOwnerId >> (==) "amazon-rds")
        >> List.head
        >> Result.fromMaybe "Could not find networkInfo for Rds"


findLoadBalancerInfo :
    { a
        | vpcId : String
        , subnetId : String
        , securityGroups : List String
    }
    -> NetworkInterfacesResponse
    -> Result String NetworkInterfaceResponse
findLoadBalancerInfo { vpcId, subnetId, securityGroups } =
    List.filter (.vpcId >> (==) vpcId)
        >> List.filter (.subnetId >> (==) subnetId)
        >> List.filter (.securityGroups >> (==) securityGroups)
        >> List.filter (\ni -> ni.instanceOwnerId == "amazon-elb" || ni.instanceOwnerId == "amazon-aws")
        >> List.head
        >> Result.fromMaybe "Could not find networkInfo for loadBalancer"


findForAddress : Ipv4Address -> NetworkInterfacesResponse -> Result String NetworkInterfaceResponse
findForAddress address =
    List.filter (.ip >> (==) address)
        >> List.head
        >> Result.fromMaybe "Could not find networkInfo"


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
