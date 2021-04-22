module Api.LoadBalancersResponse exposing
    ( LoadBalancerResponse
    , LoadBalancersResponse
    , decoder
    )

import Json.Decode as Json
import Utils.Json as Json


type alias LoadBalancersResponse =
    List LoadBalancerResponse


type alias LoadBalancerResponse =
    { subnetId : String
    , securityGroups : List String
    , vpcId : String
    , arn : String
    , publiclyAccessible : Bool
    , name : String
    }


decoder : Json.Decoder LoadBalancersResponse
decoder =
    Json.list decoder_
        |> Json.map List.concat


decoder_ : Json.Decoder (List LoadBalancerResponse)
decoder_ =
    Json.andThen buildThem decodeSubnetIds


decodeSubnetIds : Json.Decoder (List String)
decodeSubnetIds =
    Json.field "AvailabilityZones" (Json.list (Json.field "SubnetId" Json.string))


buildThem : List String -> Json.Decoder (List LoadBalancerResponse)
buildThem =
    List.map
        (\subnetId ->
            Json.map6 LoadBalancerResponse
                (Json.succeed subnetId)
                securityGroupIdsDecoder
                (Json.field "VpcId" Json.string)
                (Json.field "LoadBalancerArn" Json.string)
                decodeScheme
                (Json.field "LoadBalancerName" Json.string)
        )
        >> Json.sequence


securityGroupIdsDecoder : Json.Decoder (List String)
securityGroupIdsDecoder =
    Json.oneOf
        [ Json.field "SecurityGroups" (Json.list Json.string)
        , emptySecurityGroupsForNetworkBalancer
        ]


emptySecurityGroupsForNetworkBalancer : Json.Decoder (List String)
emptySecurityGroupsForNetworkBalancer =
    Json.field "Type" Json.string
        |> Json.andThen
            (\loadBalancerType ->
                if loadBalancerType == "network" then
                    Json.succeed []

                else
                    Json.fail "load balancer type is not network"
            )


decodeScheme : Json.Decoder Bool
decodeScheme =
    Json.field "Scheme" Json.string
        |> Json.andThen isPubliclyAccessible


isPubliclyAccessible : String -> Json.Decoder Bool
isPubliclyAccessible =
    (==) "internet-facing" >> Json.succeed
