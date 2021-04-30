module Vpc.RouteTable exposing
    ( Route
    , RouteTable
    , build
    , decoder
    , hasRouteTo
    , idAsString
    , internetGateway
    , isPublic
    )

import Cidr exposing (Cidr)
import IpAddress exposing (Ipv4Address)
import Json.Decode as Json



-- RouteTable


type RouteTable
    = RouteTable RouteTable_


type alias RouteTable_ =
    { routes : List ( Cidr, Route ) -- TODO: make it a NonEmpty List
    , id : RouteTableId
    }


type Route
    = Local
    | InternetGateway
    | NatGateway


type RouteTableId
    = RouteTableId String



-- Query


hasRouteTo : Ipv4Address -> RouteTable -> Bool
hasRouteTo toV4Address (RouteTable { routes }) =
    List.any (hasRouteTo_ toV4Address) routes


hasRouteTo_ : Ipv4Address -> ( Cidr, b ) -> Bool
hasRouteTo_ address ( cidr, _ ) =
    Cidr.contains address cidr


isPublic : RouteTable -> Bool
isPublic (RouteTable { routes }) =
    List.filter (Tuple.second >> (==) InternetGateway) routes
        |> List.isEmpty
        |> not


idAsString : RouteTable -> String
idAsString (RouteTable { id }) =
    case id of
        RouteTableId id_ ->
            id_



-- Decoder


decoder : Json.Decoder RouteTable
decoder =
    Json.field "Routes" routesDecoder
        |> Json.map (List.filterMap Basics.identity)
        |> (\rulesDecoder -> Json.map2 build rulesDecoder (Json.field "RouteTableId" Json.string))


routesDecoder : Json.Decoder (List (Maybe ( Cidr, Route )))
routesDecoder =
    Json.list
        (Json.oneOf
            [ routeDecoder
            , ignoreUntilWeSupportPrefixLists
            ]
        )


ignoreUntilWeSupportPrefixLists : Json.Decoder (Maybe ( Cidr, Route ))
ignoreUntilWeSupportPrefixLists =
    -- this is just to ignore routes that have prefix lists as destination until we support that kind of thing
    Json.succeed Nothing


routeDecoder : Json.Decoder (Maybe ( Cidr, Route ))
routeDecoder =
    Json.map2 Tuple.pair
        (Json.field "DestinationCidrBlock" Cidr.decoder)
        routeTypeDecoder
        |> Json.map Just


routeTypeDecoder : Json.Decoder Route
routeTypeDecoder =
    Json.oneOf
        [ localRouteDecoder
        , internetGatewayRouteDecoder
        , natGatewayRouteDecoder
        ]


localRouteDecoder : Json.Decoder Route
localRouteDecoder =
    Json.field "GatewayId" Json.string
        |> Json.andThen
            (\gatewayId ->
                case gatewayId of
                    "local" ->
                        Json.succeed Local

                    _ ->
                        Json.fail "could not decode local route"
            )


internetGatewayRouteDecoder : Json.Decoder Route
internetGatewayRouteDecoder =
    Json.field "GatewayId" Json.string
        |> Json.andThen
            (\gatewayId ->
                if String.contains "igw-" gatewayId then
                    Json.succeed InternetGateway

                else
                    Json.fail "could not decode internet gateway route"
            )


natGatewayRouteDecoder : Json.Decoder Route
natGatewayRouteDecoder =
    Json.field "NatGatewayId" Json.string
        |> Json.andThen
            (\natId ->
                if String.contains "nat-" natId then
                    Json.succeed NatGateway

                else
                    Json.fail "could not decode nat gateway route"
            )



-- Builder


internetGateway : Route
internetGateway =
    InternetGateway


build : List ( Cidr, Route ) -> String -> RouteTable
build rules id =
    RouteTable_ rules (RouteTableId id)
        |> RouteTable
