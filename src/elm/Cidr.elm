module Cidr exposing (Cidr, contains, range)

import IpAddress exposing (IpAddress)


type Cidr
    = Cidr IpAddress SubnetMask


type alias SubnetMask =
    Int


contains : IpAddress -> Cidr -> Bool
contains ipAddress cidr =
    True


range : Int -> Int -> Int -> Int -> SubnetMask -> Cidr
range a b c d mask =
    Cidr (IpAddress.build a b c d) mask
