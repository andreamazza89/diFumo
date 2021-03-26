module Port exposing
    ( Port
    , decoder
    , first
    , isWithin
    , last
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



-- Query


isWithin : { a | fromPort : Port, toPort : Port } -> Port -> Bool
isWithin { fromPort, toPort } givenPort =
    fromPort <= givenPort && givenPort <= toPort



-- Decoder


decoder : Json.Decoder Int
decoder =
    Json.int
