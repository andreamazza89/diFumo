module Vpc.Subnet exposing
    ( Subnet
    , build
    , idAsString
    , nodes
    )

-- Subnet

import Node exposing (Node)


type Subnet
    = Subnet
        { nodes : List Node
        , id : SubnetId
        }


type SubnetId
    = SubnetId String


nodes : Subnet -> List Node
nodes (Subnet subnet_) =
    subnet_.nodes


idAsString : Subnet -> String
idAsString (Subnet { id }) =
    case id of
        SubnetId id_ ->
            id_



-- Builder


build : String -> List Node -> Subnet
build id nodes_ =
    Subnet { id = SubnetId id, nodes = nodes_ }
