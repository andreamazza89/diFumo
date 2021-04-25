module Vpc.Subnet exposing
    ( Id
    , Subnet
    , build
    , idAsString
    , isPublic
    , name
    , nodes
    )

-- Subnet

import Node exposing (Node)
import Tag exposing (Tag)
import Vpc.RouteTable as RouteTable exposing (RouteTable)


type Subnet
    = Subnet
        { nodes : List Node
        , id : Id
        , routeTable : RouteTable
        , tags : List Tag
        }


type Id
    = Id String



-- Query


name : Subnet -> String
name ((Subnet subnet_) as sub) =
    Tag.findNameOr (idAsString sub) subnet_.tags


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


build : String -> List Node -> List Tag -> RouteTable -> Subnet
build id nodes_ tags routeTable =
    Subnet
        { id = Id id
        , nodes = nodes_
        , routeTable = routeTable
        , tags = tags
        }
