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
        ]


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
    Expect.false "some msg" (Cidr.contains address cidr_)


contains : List Int -> Maybe Cidr -> Expect.Expectation
contains address cidr_ =
    Maybe.map2 contains_ cidr_ (addressFromList address)
        |> Maybe.withDefault (Expect.fail "Could not build ip address or cidr")


contains_ : Cidr -> IpAddress.Ipv4Address -> Expect.Expectation
contains_ cidr_ address =
    Expect.true "some msg" (Cidr.contains address cidr_)
