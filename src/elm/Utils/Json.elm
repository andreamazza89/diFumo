module Utils.Json exposing (decode, key, sequence)

import Json.Decode as Json


decode : a -> Json.Decoder a
decode =
    Json.succeed


key : String -> Json.Decoder a -> Json.Decoder (a -> b) -> Json.Decoder b
key keyName decoder otherDecoder =
    Json.map2 (<|) otherDecoder (Json.field keyName decoder)


sequence : List (Json.Decoder a) -> Json.Decoder (List a)
sequence decoders =
    List.foldl collect (Json.succeed []) decoders


collect : Json.Decoder a -> Json.Decoder (List a) -> Json.Decoder (List a)
collect item acc =
    Json.andThen (\i -> Json.map ((::) i) acc) item
