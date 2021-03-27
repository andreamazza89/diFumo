module IpAddress exposing
    ( Ipv4Address
    , buildV4
    , isBetween
    , madeUpV4
    , plus
    , v4Decoder
    , v4FromString
    )

import Json.Decode as Json
import Parser exposing ((|.), (|=), Parser)



-- Ipv4Address


type Ipv4Address
    = Ipv4Address Int



-- Build


v4FromString : String -> Maybe Ipv4Address
v4FromString =
    String.replace "." "-" >> Parser.run ipv4Parser >> Result.withDefault Nothing


ipv4Parser : Parser (Maybe Ipv4Address)
ipv4Parser =
    Parser.succeed buildV4
        |= Parser.int
        |. dash
        |= Parser.int
        |. dash
        |= Parser.int
        |. dash
        |= Parser.int


dash : Parser ()
dash =
    Parser.symbol "-"


madeUpV4 : Ipv4Address
madeUpV4 =
    Ipv4Address 167772160


buildV4 : Int -> Int -> Int -> Int -> Maybe Ipv4Address
buildV4 a b c d =
    if numberIsWithinRange a && numberIsWithinRange b && numberIsWithinRange c && numberIsWithinRange d then
        Just (Ipv4Address (d + (256 * c) + ((256 ^ 2) * b) + ((256 ^ 3) * a)))

    else
        Nothing


numberIsWithinRange : number -> Bool
numberIsWithinRange n =
    n >= 0 && n <= 255



-- Query


isBetween : Ipv4Address -> Ipv4Address -> Ipv4Address -> Bool
isBetween (Ipv4Address lower) (Ipv4Address upper) (Ipv4Address address) =
    address >= lower && address <= upper



-- Update


plus : Ipv4Address -> Int -> Ipv4Address
plus (Ipv4Address address) number =
    -- this is slightly dangerous as it could return an invalid ip address (e.g. 255.255.255.255 + 1), but the
    -- likelihood of it happening vs the ergonomics of making this Maybe made me leave it as 'dangerous'
    Ipv4Address (address + number - 1)



-- Decode


v4Decoder : Json.Decoder Ipv4Address
v4Decoder =
    Json.andThen v4Decoder_ Json.string


v4Decoder_ : String -> Json.Decoder Ipv4Address
v4Decoder_ =
    v4FromString
        >> Maybe.map Json.succeed
        >> Maybe.withDefault (Json.fail "could not parse ip")
