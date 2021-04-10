module Api.RdsResponse exposing (RdsResponse, RdsesResponse, decoder)

import IpAddress exposing (Ipv4Address)
import Json.Decode as Json


type alias RdsesResponse =
    List RdsResponse


type alias RdsResponse =
    { id : String
    , securityGroups : List String
    , publicIp : Maybe Ipv4Address
    , subnetIds : List String
    , vpcId : String
    }


type alias SubnetResponse =
    { availabilityZone : String
    , subnetId : String
    }


decoder : Json.Decoder RdsesResponse
decoder =
    Json.list decoder_


decoder_ : Json.Decoder RdsResponse
decoder_ =
    Json.map5 RdsResponse
        (Json.field "DBInstanceIdentifier" Json.string)
        (Json.field "VpcSecurityGroups" securityGroupsDecoder)
        (Json.succeed Nothing)
        subnetIdsDecoder
        (Json.at [ "DBSubnetGroup", "VpcId" ] Json.string)


securityGroupsDecoder : Json.Decoder (List String)
securityGroupsDecoder =
    Json.list (Json.field "VpcSecurityGroupId" Json.string)


subnetIdsDecoder : Json.Decoder (List String)
subnetIdsDecoder =
    Json.at [ "DBSubnetGroup", "Subnets" ] (Json.list (Json.field "SubnetIdentifier" Json.string))
