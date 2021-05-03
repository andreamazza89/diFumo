module Vpc exposing
    ( Id
    , Vpc
    , build
    , equals
    , idAsString
    , privateSubnets
    , publicSubnets
    )

import Vpc.Subnet as Subnet exposing (Subnet)



-- Vpc


type Vpc
    = Vpc
        { subnets : List Subnet
        , id : Id
        }


type Id
    = Id String



-- Query


id : Vpc -> Id
id (Vpc vpc_) =
    vpc_.id


privateSubnets : Vpc -> List Subnet
privateSubnets (Vpc vpc_) =
    List.filter (Subnet.isPublic >> not) vpc_.subnets


publicSubnets : Vpc -> List Subnet
publicSubnets (Vpc vpc_) =
    List.filter Subnet.isPublic vpc_.subnets


idAsString : Vpc -> String
idAsString vpc =
    case id vpc of
        Id id_ ->
            id_


equals : Vpc -> Vpc -> Bool
equals one theOther =
    id one == id theOther



-- Builder


build : String -> List Subnet -> Vpc
build id_ subnets_ =
    Vpc
        { id = Id id_
        , subnets = subnets_
        }
