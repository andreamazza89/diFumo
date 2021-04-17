module Api.LoadBalancersResponse exposing
    ( LoadBalancerResponse
    , LoadBalancersResponse
    , decoder
    )

import Json.Decode as Json


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
                (Json.field "SecurityGroups" (Json.list Json.string))
                (Json.field "VpcId" Json.string)
                (Json.field "LoadBalancerArn" Json.string)
                decodeScheme
                -- FIX THIS TO NOT BE CANNED
                (Json.field "LoadBalancerName" Json.string)
        )
        >> sequence


decodeScheme : Json.Decoder Bool
decodeScheme =
    Json.field "Scheme" Json.string
        |> Json.andThen isPubliclyAccessible


isPubliclyAccessible : String -> Json.Decoder Bool
isPubliclyAccessible =
    (==) "internet-facing" >> Json.succeed


sequence : List (Json.Decoder a) -> Json.Decoder (List a)
sequence decoders =
    List.foldl collect (Json.succeed []) decoders


collect : Json.Decoder a -> Json.Decoder (List a) -> Json.Decoder (List a)
collect item acc =
    Json.andThen (\i -> Json.map ((::) i) acc) item
