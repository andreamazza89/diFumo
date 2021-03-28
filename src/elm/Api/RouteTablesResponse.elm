module Api.RouteTablesResponse exposing
    ( RouteTablesResponse
    , decoder
    )

import Json.Decode as Json
import Vpc.RouteTable as RouteTable exposing (RouteTable)


type alias RouteTablesResponse =
    { explicit : List ExplicitRouteTableResponse
    , implicit : List ImplicitRouteTableResponse
    }


type alias RouteTableResponse =
    { subnetsAssociated : List SubnetId
    , vpcId : VpcId
    , table : RouteTable
    }


type alias ExplicitRouteTableResponse =
    ( List SubnetId, RouteTable )


type alias ImplicitRouteTableResponse =
    -- The default (Main) route table is implicitly associated to any subnets that have not been explicitly associated
    -- with any other route tables
    ( VpcId, RouteTable )


type alias SubnetId =
    String


type alias VpcId =
    String


decoder : Json.Decoder RouteTablesResponse
decoder =
    Json.map2 RouteTablesResponse
        explicitTablesDecoder
        implicitTablesDecoder


explicitTablesDecoder : Json.Decoder (List ExplicitRouteTableResponse)
explicitTablesDecoder =
    Json.list routeTableDecoder
        |> Json.map (List.filterMap toExplicitTable)


routeTableDecoder : Json.Decoder RouteTableResponse
routeTableDecoder =
    Json.map3 RouteTableResponse
        subnetAssociationsDecoder
        vpcIdDecoder
        RouteTable.decoder


implicitTablesDecoder : Json.Decoder (List ImplicitRouteTableResponse)
implicitTablesDecoder =
    Json.list routeTableDecoder
        |> Json.map (List.filterMap toImplicitTable)


toExplicitTable : RouteTableResponse -> Maybe ( List SubnetId, RouteTable )
toExplicitTable tableResponse =
    if List.isEmpty tableResponse.subnetsAssociated then
        Nothing

    else
        Just ( tableResponse.subnetsAssociated, tableResponse.table )


toImplicitTable : RouteTableResponse -> Maybe ( VpcId, RouteTable )
toImplicitTable tableResponse =
    if List.isEmpty tableResponse.subnetsAssociated then
        Just ( tableResponse.vpcId, tableResponse.table )

    else
        Nothing


subnetAssociationsDecoder : Json.Decoder (List SubnetId)
subnetAssociationsDecoder =
    Json.field "Associations" (Json.list subnetAssociationDecoder)
        |> Json.map (List.filterMap identity)


subnetAssociationDecoder : Json.Decoder (Maybe SubnetId)
subnetAssociationDecoder =
    Json.field "Main" Json.bool
        |> Json.andThen
            (\isMain ->
                if isMain then
                    Json.succeed Nothing

                else
                    Json.field "SubnetId" Json.string
                        |> Json.map Just
            )


vpcIdDecoder : Json.Decoder VpcId
vpcIdDecoder =
    Json.field "VpcId" Json.string
