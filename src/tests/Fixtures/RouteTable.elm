module Fixtures.RouteTable exposing (internetTable, localTable)

import Cidr
import Vpc.RouteTable as RouteTable exposing (RouteTable)



-- Route Table Fixture


localTable : RouteTable
localTable =
    RouteTable.build []


internetTable : RouteTable
internetTable =
    RouteTable.build [ ( Cidr.everywhere, RouteTable.internetGateway ) ]
