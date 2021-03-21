module Vpc.Subnet exposing
    ( Id
    , Subnet
    , build
    , buildId
    , idAsString
    , nodes
    )

-- Subnet

import Node exposing (Node)


type Subnet
    = Subnet
        { nodes : List Node
        , id : Id
        }


type Id
    = Id String


nodes : Subnet -> List Node
nodes (Subnet subnet_) =
    subnet_.nodes


idAsString : Subnet -> String
idAsString (Subnet { id }) =
    case id of
        Id id_ ->
            id_



-- Builder


build : String -> List Node -> Subnet
build id nodes_ =
    Subnet { id = Id id, nodes = nodes_ }


buildId : String -> Id
buildId id_ =
    Id id_
