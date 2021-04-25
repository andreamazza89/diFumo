module Vpc.Subnet exposing
    ( Id
    , Subnet
    , build
    , idAsString
    , isPublic
    , nodes
    )

-- Subnet

import Node exposing (Node)
import Vpc.RouteTable as RouteTable exposing (RouteTable)


type Subnet
    = Subnet
        { nodes : List Node
        , id : Id
        , routeTable : RouteTable
        }


type Id
    = Id String



-- Query


nodes : Subnet -> List Node
nodes (Subnet subnet_) =
    subnet_.nodes


idAsString : Subnet -> String
idAsString (Subnet { id }) =
    case id of
        Id id_ ->
            id_


isPublic : Subnet -> Bool
isPublic (Subnet { routeTable }) =
    RouteTable.isPublic routeTable



-- Builder


build : String -> List Node -> RouteTable -> Subnet
build id nodes_ routeTable =
    Subnet
        { id = Id id
        , nodes = nodes_
        , routeTable = routeTable
        }
