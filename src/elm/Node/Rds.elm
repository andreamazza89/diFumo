module Node.Rds exposing
    ( Config
    , Rds
    , build
    , canAccessInternet
    , equals
    , idAsString
    )

-- Rds Node specifics

import IpAddress exposing (Ipv4Address)


type Rds
    = Rds
        { id : RdsId
        , publicIp : Maybe Ipv4Address
        }


type RdsId
    = RdsId String


id : Rds -> RdsId
id (Rds rds) =
    rds.id


idAsString : Rds -> String
idAsString rds =
    case id rds of
        RdsId id_ ->
            id_


equals : Rds -> Rds -> Bool
equals one theOther =
    id one == id theOther


canAccessInternet : Rds -> Bool
canAccessInternet (Rds { publicIp }) =
    case publicIp of
        Just _ ->
            True

        Nothing ->
            False



-- Build


type alias Config a =
    { a
        | id : String
        , publicIp : Maybe Ipv4Address
    }


build : Config a -> Rds
build config =
    Rds
        { id = RdsId config.id
        , publicIp = config.publicIp
        }
