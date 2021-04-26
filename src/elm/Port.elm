module Port exposing
    ( Port
    , decoder
    , first
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
