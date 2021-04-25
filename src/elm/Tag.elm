module Tag exposing (Tag, decoder, findName)

import Json.Decode as Json


type alias Tag =
    { name : String
    , value : String
    }


findName : List Tag -> Maybe String
findName =
    List.filter (.name >> String.toLower >> (==) "name")
        >> List.head
        >> Maybe.map .value


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
