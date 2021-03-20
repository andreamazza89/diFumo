module IpAddress exposing (IpAddress, build)


type IpAddress
    = IpAddress Int Int Int Int



-- Builder


build : Int -> Int -> Int -> Int -> IpAddress
build =
    IpAddress
