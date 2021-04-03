module Fixtures.IpAddress exposing (fromList, fuzzAny)

import Fuzz exposing (Fuzzer)
import IpAddress exposing (Ipv4Address)


fuzzAny : Fuzzer (Maybe Ipv4Address)
fuzzAny =
    Fuzz.intRange 0 4294967295
        |> Fuzz.map IpAddress.v4FromInt


fromList : List Int -> Maybe IpAddress.Ipv4Address
fromList address =
    case address of
        [ a, b, c, d ] ->
            IpAddress.buildV4 a b c d

        _ ->
            Nothing
