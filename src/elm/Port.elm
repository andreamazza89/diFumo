module Port exposing
    ( Port
    , first
    , isWithin
    , last
    )


type alias Port =
    Int


first : Port
first =
    0


last : Port
last =
    65535


isWithin : { a | fromPort : Port, toPort : Port } -> Port -> Bool
isWithin { fromPort, toPort } givenPort =
    fromPort <= givenPort && givenPort <= toPort
