module Cidr exposing (Cidr, SubnetMask, build, contains)

import IpAddress exposing (Ipv4Address)


type Cidr
    = Cidr Ipv4Address SubnetMask


type alias SubnetMask =
    Int


contains : Ipv4Address -> Cidr -> Bool
contains ipAddress cidr =
    IpAddress.isBetween (firstIpInRange cidr) (lastIpInRange cidr) ipAddress


firstIpInRange : Cidr -> Ipv4Address
firstIpInRange (Cidr firstAddress _) =
    firstAddress


lastIpInRange : Cidr -> Ipv4Address
lastIpInRange (Cidr firstAddress mask) =
    IpAddress.plus firstAddress (subnetSize mask)


subnetSize : number -> number
subnetSize mask =
    -- this is for ipv4. In ipv6 the magic number is 128 instead of 32
    2 ^ (32 - mask)



-- TODO: When building a cidr, if the ip supplied is in the middle of the range, the builder should default to the first one
-- for example, given 10.0.0.55/16 the ip used should be 10.0.0.0


build : SubnetMask -> Ipv4Address -> Maybe Cidr
build mask address =
    if mask > 0 && mask <= 32 then
        Just (Cidr address mask)

    else
        Nothing
