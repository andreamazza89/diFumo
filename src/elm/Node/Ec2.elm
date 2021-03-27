module Node.Ec2 exposing
    ( Config
    , Ec2
    , build
    , equals
    , hasInternetRoute
    , idAsString
    )


type Ec2
    = Ec2 { id : Ec2Id }


type Ec2Id
    = Ec2Id String


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


hasInternetRoute : Ec2 -> Bool
hasInternetRoute (Ec2 _) =
    True



-- Builders


type alias Config a =
    { a | id : String }


build : Config a -> Ec2
build config =
    Ec2
        { id = Ec2Id config.id }
