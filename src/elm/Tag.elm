module Tag exposing (Tag, decoder, findNameOr)

import Json.Decode as Json


type alias Tag =
    { name : String
    , value : String
    }


findNameOr : String -> List Tag -> String
findNameOr default =
    List.filter (.name >> String.toLower >> (==) "name")
        >> List.head
        >> Maybe.map .value
        >> Maybe.withDefault default


decoder : Json.Decoder (List Tag)
decoder =
    Json.field "Tags" decoder_


decoder_ : Json.Decoder (List Tag)
decoder_ =
    Json.list
        (Json.map2 Tag
            (Json.field "Key" Json.string)
            (Json.field "Value" Json.string)
        )
