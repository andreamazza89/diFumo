module Utils.Json exposing (decode, key)

import Json.Decode as Json


decode : a -> Json.Decoder a
decode =
    Json.succeed


key : String -> Json.Decoder a -> Json.Decoder (a -> b) -> Json.Decoder b
key keyName decoder otherDecoder =
    Json.map2 (<|) otherDecoder (Json.field keyName decoder)
