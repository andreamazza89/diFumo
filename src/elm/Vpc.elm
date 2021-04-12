module Vpc exposing
    ( Id
    , Vpc
    , build
    , idAsString
    , subnets
    )

import Vpc.Subnet exposing (Subnet)



-- Vpc


type Vpc
    = Vpc
        { subnets : List Subnet
        , id : Id
        }


type Id
    = Id String



-- Query


subnets : Vpc -> List Subnet
subnets (Vpc vpc_) =
    vpc_.subnets


idAsString : Vpc -> String
idAsString (Vpc { id }) =
    case id of
        Id id_ ->
            id_



-- Builder


build : String -> List Subnet -> Vpc
build id subnets_ =
    Vpc
        { id = Id id
        , subnets = subnets_
        }
