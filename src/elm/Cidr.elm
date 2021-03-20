module Cidr exposing (Cidr, contains)

import IpAddress exposing (IpAddress)


type Cidr
    = Host IpAddress


contains : IpAddress -> Cidr -> Bool
contains ipAddress cidr =
    True
