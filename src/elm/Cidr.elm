module Cidr exposing (Cidr, build, contains)

import IpAddress exposing (Ipv4Address)


type Cidr
    = Cidr Ipv4Address SubnetMask


type alias SubnetMask =
    Int


contains : Ipv4Address -> Cidr -> Bool
contains ipAddress cidr =
    ipAddress == firstIpInRange cidr


firstIpInRange : Cidr -> Ipv4Address
firstIpInRange (Cidr ipAddress _) =
    ipAddress


build : SubnetMask -> Ipv4Address -> Maybe Cidr
build mask address =
    if mask > 0 && mask <= 32 then
        Just (Cidr address mask)

    else
        Nothing
