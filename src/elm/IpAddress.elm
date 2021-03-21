module IpAddress exposing (Ipv4Address, buildV4, isBetween, madeUpV4, plus)


type Ipv4Address
    = Ipv4Address Int



-- Builder


madeUpV4 : Ipv4Address
madeUpV4 =
    Ipv4Address 167772160


buildV4 : Int -> Int -> Int -> Int -> Maybe Ipv4Address
buildV4 a b c d =
    if numberIsWithinRange a && numberIsWithinRange b && numberIsWithinRange c && numberIsWithinRange d then
        Just (Ipv4Address (d + (256 * c) + ((256 ^ 2) * b) + ((256 ^ 3) * a)))

    else
        Nothing


numberIsWithinRange : number -> Bool
numberIsWithinRange n =
    n >= 0 && n <= 255


isBetween : Ipv4Address -> Ipv4Address -> Ipv4Address -> Bool
isBetween (Ipv4Address lower) (Ipv4Address upper) (Ipv4Address address) =
    address >= lower && address <= upper


plus : Ipv4Address -> Int -> Ipv4Address
plus (Ipv4Address address) number =
    -- this is slightly dangerous as it could return an invalid ip address (e.g. 255.255.255.255 + 1), but the
    -- likelihood of it happening vs the ergonomics of making this Maybe made me leave it as 'dangerous'
    Ipv4Address (address + number - 1)
