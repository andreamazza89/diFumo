module Node.Ec2 exposing
    ( Config
    , Ec2
    , build
    , canAccessInternet
    , equals
    , idAsString
    , name
    )

import IpAddress exposing (Ipv4Address)
import Tag exposing (Tag)



-- Ec2 Node specifics


type Ec2
    = Ec2
        { id : Ec2Id
        , publicIp : Maybe Ipv4Address
        , tags : List Tag
        }


type Ec2Id
    = Ec2Id String



-- Query


name : Ec2 -> String
name ((Ec2 ec2) as instance) =
    Tag.findName ec2.tags
        |> Maybe.withDefault (idAsString instance)


equals : Ec2 -> Ec2 -> Bool
equals ec2 otherEc2 =
    id ec2 == id otherEc2


id : Ec2 -> Ec2Id
id (Ec2 ec2_) =
    ec2_.id


idAsString : Ec2 -> String
idAsString ec2 =
    case id ec2 of
        Ec2Id id_ ->
            id_


canAccessInternet : Ec2 -> Bool
canAccessInternet (Ec2 { publicIp }) =
    case publicIp of
        Just _ ->
            True

        Nothing ->
            False



-- Builders


type alias Config a =
    { a
        | id : String
        , publicIp : Maybe Ipv4Address
        , tags : List Tag
    }


build : Config a -> Ec2
build config =
    Ec2
        { id = Ec2Id config.id
        , publicIp = config.publicIp
        , tags = config.tags
        }
