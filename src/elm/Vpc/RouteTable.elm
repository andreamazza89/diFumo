module Vpc.RouteTable exposing
    ( Route
    , RouteTable
    , build
    , hasRouteTo
    , internetGateway
    )

import Cidr exposing (Cidr)
import IpAddress exposing (Ipv4Address)



-- RouteTable


type RouteTable
    = RouteTable RouteTable_


type alias RouteTable_ =
    { routes : List ( Cidr, Route ) }


type Route
    = Local
    | InternetGateway



-- Query


hasRouteTo : Ipv4Address -> RouteTable -> Bool
hasRouteTo toV4Address (RouteTable { routes }) =
    List.any (hasRouteTo_ toV4Address) routes


hasRouteTo_ : Ipv4Address -> ( Cidr, b ) -> Bool
hasRouteTo_ address ( cidr, _ ) =
    Cidr.contains address cidr



-- Builder


internetGateway : Route
internetGateway =
    InternetGateway


build : List ( Cidr, Route ) -> RouteTable
build =
    RouteTable_ >> RouteTable
