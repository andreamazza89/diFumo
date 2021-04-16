module Api.EcsTasksResponse exposing
    ( EcsTaskResponse
    , EcsTasksResponse
    , decoder
    )

import IpAddress exposing (Ipv4Address)
import Json.Decode as Json


type alias EcsTasksResponse =
    List EcsTaskResponse


type alias EcsTaskResponse =
    { arn : String
    , ip : Ipv4Address
    , group : String
    }


decoder : Json.Decoder (List EcsTaskResponse)
decoder =
    Json.list decoder_


decoder_ : Json.Decoder EcsTaskResponse
decoder_ =
    Json.map3 EcsTaskResponse
        (Json.field "taskArn" Json.string)
        (Json.field "attachments" (Json.index 0 (Json.field "details" decodeIp)))
        (Json.field "group" Json.string)


decodeIp : Json.Decoder Ipv4Address
decodeIp =
    decodeDetail
        |> Json.andThen
            (List.filter (.name >> (==) "privateIPv4Address")
                >> List.head
                >> Maybe.map (.value >> IpAddress.v4FromString >> Maybe.map Json.succeed >> Maybe.withDefault (Json.fail "could not find ip address for task"))
                >> Maybe.withDefault (Json.fail "could not find ip address for task")
            )


decodeDetail : Json.Decoder (List { name : String, value : String })
decodeDetail =
    Json.list
        (Json.map2 (\name value -> { name = name, value = value })
            (Json.field "name" Json.string)
            (Json.field "value" Json.string)
        )
