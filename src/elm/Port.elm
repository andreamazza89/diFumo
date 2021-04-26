module Port exposing
    ( Port
    , decoder
    , first
    , fromString
    , https
    , isWithin
    , last
    , toString
    )

-- Port

import Json.Decode as Json


type alias Port =
    Int



-- Build


fromString : String -> Maybe Port
fromString =
    String.toInt >> Maybe.andThen build


build : Int -> Maybe Port
build n =
    if n >= first && n <= last then
        Just n

    else
        Nothing


first : Port
first =
    0


last : Port
last =
    65535


https : Port
https =
    443



-- Query


isWithin : { a | fromPort : Port, toPort : Port } -> Port -> Bool
isWithin { fromPort, toPort } givenPort =
    fromPort <= givenPort && givenPort <= toPort


toString : Port -> String
toString =
    String.fromInt



-- Decoder


decoder : Json.Decoder Int
decoder =
    Json.int
