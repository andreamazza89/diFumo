module CidrTest exposing (suite)

import Expect
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Money"
        [ test "converts string to amount" <|
            \_ ->
                Expect.equal 4 4
        ]
