module CidrTest exposing (suite)

import Cidr
import Expect
import IpAddress
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Cidr"
        [ test "Single-address range (32) matches on the address" <|
            \_ ->
                IpAddress.buildV4 1 1 1 1
                    |> Maybe.andThen
                        (\address ->
                            Cidr.build 32 address
                                |> Maybe.map (Cidr.contains address)
                                |> Maybe.map (Expect.true "should contain the base range address")
                        )
                    |> Maybe.withDefault (Expect.fail "hi")
        , test "Single-address range (32) does not match on a different address" <|
            \_ ->
                Maybe.map2 (\cidr someAddress -> Expect.false "bla" (Cidr.contains someAddress cidr))
                    (IpAddress.buildV4 1 1 1 1 |> Maybe.andThen (Cidr.build 32))
                    (IpAddress.buildV4 1 2 3 4)
                    |> Maybe.withDefault (Expect.fail "hi")
        ]
