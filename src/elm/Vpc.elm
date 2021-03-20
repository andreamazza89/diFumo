module Vpc exposing
    ( Vpc
    , build
    , idAsString
    , subnets
    )

-- Vpc

import Vpc.Subnet exposing (Subnet)


type Vpc
    = Vpc
        { subnets : List Subnet
        , id : VpcId
        }


type VpcId
    = VpcId String


subnets : Vpc -> List Subnet
subnets (Vpc vpc_) =
    vpc_.subnets


idAsString : Vpc -> String
idAsString (Vpc { id }) =
    case id of
        VpcId id_ ->
            id_



-- Builder


build : String -> List Subnet -> Vpc
build id subnets_ =
    Vpc { id = VpcId id, subnets = subnets_ }
