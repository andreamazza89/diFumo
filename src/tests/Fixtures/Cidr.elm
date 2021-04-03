module Fixtures.Cidr exposing (cidr, everywhere)

import Cidr exposing (Cidr)
import Fixtures.IpAddress as IpAddress


everywhere : Maybe Cidr
everywhere =
    Just Cidr.everywhere


cidr : List Int -> Cidr.SubnetMask -> Maybe Cidr
cidr address mask =
    IpAddress.fromList address
        |> Maybe.andThen (Cidr.build mask)
