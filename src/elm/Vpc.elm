module Vpc exposing
    ( Id
    , Vpc
    , build
    , buildId
    , idAsString
    , subnets
    )

-- Vpc

import Vpc.Subnet exposing (Subnet)


type Vpc
    = Vpc
        { subnets : List Subnet
        , id : Id
        }


type Id
    = Id String


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
    Vpc { id = Id id, subnets = subnets_ }


buildId : String -> Id
buildId id_ =
    Id id_
