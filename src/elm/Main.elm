module Main exposing (main)

import AwsFixtures.Elm as Fixtures
import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Html exposing (Html)
import Node exposing (Node)
import Vpc exposing (Vpc)
import Vpc.Subnet as Subnet exposing (Subnet)


main : Program () Model a
main =
    Browser.sandbox
        { init = NothingSelected
        , view = view
        , update = update
        }


type Model
    = NothingSelected
    | SourceNode Node
    | Path { from : Node, to : Node }


view : a -> Html msg
view _ =
    Element.layout [ padding 5 ] (theWorld Fixtures.myVpc)


update msg model =
    NothingSelected


theWorld : Vpc -> Element msg
theWorld vpc =
    row
        [ width fill
        , height fill
        , spacing 10
        ]
        [ viewVpc vpc
        , el
            [ Border.width 2
            , Border.rounded 10
            , padding 5
            , pointer
            ]
            (text "internet")
        ]


viewVpc : Vpc -> Element msg
viewVpc vpc =
    column
        [ width fill
        , height fill
        , Border.width 2
        , spacing 15
        , padding 10
        ]
        [ text ("vpc: " ++ Vpc.idAsString vpc)
        , viewSubnets (Vpc.subnets vpc)
        ]


viewSubnets : List Subnet -> Element msg
viewSubnets =
    List.map viewSubnet >> column [ spacing 5, width fill, height fill ]


viewSubnet : Subnet -> Element msg
viewSubnet subnet_ =
    column
        [ Border.width 2
        , Background.color (rgb 0 0.5 0)
        , width fill
        , padding 10
        , spacing 10
        ]
        [ text ("subnet: " ++ Subnet.idAsString subnet_)
        , viewNodes (Subnet.nodes subnet_)
        ]


viewNodes : List Node -> Element msg
viewNodes =
    List.map viewNode >> row [ spacing 5 ]


viewNode : Node -> Element msg
viewNode node_ =
    el
        [ Border.width 2
        , Border.rounded 10
        , padding 5
        , pointer
        ]
        (text ("ec2  " ++ Node.idAsString node_))
