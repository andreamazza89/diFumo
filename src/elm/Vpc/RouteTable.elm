module Vpc.RouteTable exposing
    ( Route
    , RouteTable
    , build
    , decoder
    , hasRouteTo
    , internetGateway
    )

import Cidr exposing (Cidr)
import IpAddress exposing (Ipv4Address)
import Json.Decode as Json



-- RouteTable


type RouteTable
    = RouteTable RouteTable_


type alias RouteTable_ =
    { routes : List ( Cidr, Route ) -- TODO: make it a NonEmpty List
    }


type Route
    = Local
    | InternetGateway
    | NatGateway



-- Query


hasRouteTo : Ipv4Address -> RouteTable -> Bool
hasRouteTo toV4Address (RouteTable { routes }) =
    List.any (hasRouteTo_ toV4Address) routes


hasRouteTo_ : Ipv4Address -> ( Cidr, b ) -> Bool
hasRouteTo_ address ( cidr, _ ) =
    Cidr.contains address cidr



-- Decoder


decoder : Json.Decoder RouteTable
decoder =
    Json.field "Routes" routesDecoder
        |> Json.map build


routesDecoder : Json.Decoder (List ( Cidr, Route ))
routesDecoder =
    Json.list routeDecoder


routeDecoder : Json.Decoder ( Cidr, Route )
routeDecoder =
    Json.map2 Tuple.pair
        (Json.field "DestinationCidrBlock" Cidr.decoder)
        routeTypeDecoder


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


build : List ( Cidr, Route ) -> RouteTable
build =
    RouteTable_ >> RouteTable
