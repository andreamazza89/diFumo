module CidrTest exposing (suite)

import Cidr exposing (Cidr)
import Expect
import IpAddress
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Cidr"
        [ test "Single-address range (32) matches on the address" <|
            \_ ->
                cidr [ 1, 1, 1, 1 ] 32
                    |> contains [ 1, 1, 1, 1 ]
        , test "Single-address range (32) does not match on a different address" <|
            \_ ->
                cidr [ 1, 1, 1, 1 ] 32
                    |> doesNotContain [ 1, 2, 3, 4 ]
        , test "Matching on a wider range (address is at the beginning of the range)" <|
            \_ ->
                cidr [ 10, 0, 0, 0 ] 16
                    |> contains [ 10, 0, 0, 0 ]
        , test "Matching on a wider range (address is within range)" <|
            \_ ->
                cidr [ 10, 0, 0, 0 ] 16
                    |> contains [ 10, 0, 111, 33 ]
        , test "Matching on a wider range (address is at the end of the range)" <|
            \_ ->
                cidr [ 10, 0, 0, 0 ] 16
                    |> contains [ 10, 0, 255, 255 ]
        , test "Matching on a wider range (address is above the range)" <|
            \_ ->
                cidr [ 10, 0, 0, 0 ] 16
                    |> doesNotContain [ 10, 1, 0, 0 ]
        , test "Matching on a wider range (address is below the range)" <|
            \_ ->
                cidr [ 10, 0, 0, 0 ] 16
                    |> doesNotContain [ 9, 255, 255, 255 ]
        , test "The 'everywhere' cidr matches any address" <|
            \_ ->
                everywhereCidr
                    |> contains [ 1, 2, 3, 4 ]
        ]


everywhereCidr : Maybe Cidr
everywhereCidr =
    Just Cidr.everywhere


cidr : List Int -> Cidr.SubnetMask -> Maybe Cidr
cidr address mask =
    addressFromList address
        |> Maybe.andThen (Cidr.build mask)


addressFromList : List Int -> Maybe IpAddress.Ipv4Address
addressFromList address =
    case address of
        [ a, b, c, d ] ->
            IpAddress.buildV4 a b c d

        _ ->
            Nothing


doesNotContain : List Int -> Maybe Cidr -> Expect.Expectation
doesNotContain address cidr_ =
    Maybe.map2 doesNotContain_ cidr_ (addressFromList address)
        |> Maybe.withDefault (Expect.fail "Could not build ip address or cidr")


doesNotContain_ : Cidr -> IpAddress.Ipv4Address -> Expect.Expectation
doesNotContain_ cidr_ address =
    Expect.false "Given address was NOT expected to be contained in given cidr" (Cidr.contains address cidr_)


contains : List Int -> Maybe Cidr -> Expect.Expectation
contains address cidr_ =
    Maybe.map2 contains_ cidr_ (addressFromList address)
        |> Maybe.withDefault (Expect.fail "Could not build ip address or cidr")


contains_ : Cidr -> IpAddress.Ipv4Address -> Expect.Expectation
contains_ cidr_ address =
    Expect.true "Given address was expected to be contained in given cidr but was NOT" (Cidr.contains address cidr_)
