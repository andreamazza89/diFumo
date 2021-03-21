module Cidr exposing (Cidr, contains, range)

import IpAddress exposing (Ipv4Address)


type Cidr
    = Cidr Ipv4Address SubnetMask


type alias SubnetMask =
    Int


contains : Ipv4Address -> Cidr -> Bool
contains ipAddress cidr =
    True


range : Int -> Int -> Int -> Int -> SubnetMask -> Cidr
range a b c d mask =
    Cidr (IpAddress.buildV4 a b c d) mask
