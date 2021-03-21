module IpAddress exposing (Ipv4Address, buildV4)


type Ipv4Address
    = Ipv4Address Int



-- Builder


buildV4 : Int -> Int -> Int -> Int -> Maybe Ipv4Address
buildV4 a b c d =
    if numberIsWithinRange a && numberIsWithinRange b && numberIsWithinRange c && numberIsWithinRange d then
        Just (Ipv4Address (d + (256 * c) + ((256 ^ 2) * b) + ((256 ^ 3) * a)))

    else
        Nothing


numberIsWithinRange : number -> Bool
numberIsWithinRange n =
    n >= 0 && n <= 255
