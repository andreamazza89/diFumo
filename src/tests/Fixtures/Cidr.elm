module Fixtures.Cidr exposing (cidr, everyWhere)

import Cidr exposing (Cidr)
import Fixtures.IpAddress as IpAddress


everyWhere : Maybe Cidr
everyWhere =
    Just Cidr.everywhere


cidr : List Int -> Cidr.SubnetMask -> Maybe Cidr
cidr address mask =
    IpAddress.fromList address
        |> Maybe.andThen (Cidr.build mask)
