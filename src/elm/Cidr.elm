module Cidr exposing
    ( Cidr
    , SubnetMask
    , build
    , contains
    , decoder
    , everywhere
    , fromString
    )

import IpAddress exposing (Ipv4Address)
import Json.Decode as Json
import Parser exposing ((|.), (|=), Parser)



-- Cidr
--   - stands for Classless Inter-Domain Routing
--   - it represents a range of addresses
--   - looks like  10.0.0.0 / 16
--    first in range---^       ^---range size


type Cidr
    = Cidr Ipv4Address SubnetMask
    | Everywhere


type alias SubnetMask =
    Int


contains : Ipv4Address -> Cidr -> Bool
contains ipAddress cidr =
    case cidr of
        Cidr firstIp subnetMask ->
            IpAddress.isBetween firstIp (lastIpInRange firstIp subnetMask) ipAddress

        Everywhere ->
            True


lastIpInRange : Ipv4Address -> SubnetMask -> Ipv4Address
lastIpInRange firstAddress mask =
    IpAddress.plus firstAddress (subnetSize mask)


subnetSize : number -> number
subnetSize mask =
    -- this is for ipv4. In ipv6 the magic number is 128 instead of 32
    2 ^ (32 - mask)



-- TODO: When building a cidr, if the ip supplied is in the middle of the range, the builder should default to the first one
-- for example, given 10.0.0.55/16 the ip used should be 10.0.0.0


everywhere : Cidr
everywhere =
    Everywhere


build : SubnetMask -> Ipv4Address -> Maybe Cidr
build mask address =
    if mask > 0 && mask <= 32 then
        Just (Cidr address mask)

    else
        Nothing


fromString : String -> Maybe Cidr
fromString string =
    if string == "0.0.0.0/0" then
        Just Everywhere

    else
        Maybe.map2 build
            (parseSubnetMask string)
            (IpAddress.v4FromString string)
            |> Maybe.withDefault Nothing


parseSubnetMask : String -> Maybe Int
parseSubnetMask string =
    Parser.run subnetMaskParser string
        |> Result.map Just
        |> Result.withDefault Nothing


subnetMaskParser : Parser Int
subnetMaskParser =
    Parser.succeed identity
        |. Parser.chompUntil "/"
        |. Parser.symbol "/"
        |= Parser.int



-- Decoder


decoder : Json.Decoder Cidr
decoder =
    Json.andThen decoder_ Json.string


decoder_ : String -> Json.Decoder Cidr
decoder_ =
    fromString
        >> Maybe.map Json.succeed
        >> Maybe.withDefault (Json.fail "could not parse cidr")
