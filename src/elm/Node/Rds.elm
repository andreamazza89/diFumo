module Node.Rds exposing
    ( Config
    , Rds
    , build
    , canAccessInternet
    , equals
    , idAsString
    )

-- Rds Node specifics


type Rds
    = Rds
        { id : RdsId
        , publiclyAccessible : Bool
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
canAccessInternet (Rds { publiclyAccessible }) =
    publiclyAccessible



-- Build


type alias Config a =
    { a
        | id : String
        , isPubliclyAccessible : Bool
    }


build : Config a -> Rds
build config =
    Rds
        { id = RdsId config.id
        , publiclyAccessible = config.isPubliclyAccessible
        }
