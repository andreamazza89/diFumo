module Main exposing (main)

import AwsFixtures.Elm as Fixtures
import Browser
import Connectivity
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Html exposing (Html)
import Node exposing (Node)
import Port exposing (Port)
import Protocol
import Vpc exposing (Vpc)
import Vpc.Subnet as Subnet exposing (Subnet)


main : Program () Model Msg
main =
    Browser.sandbox
        { init = NothingSelected
        , view = view
        , update = update
        }


type Model
    = NothingSelected
    | SourceNode Node
    | Path { from : Node, to : Node } Port


type Msg
    = NodeClicked Node


view : Model -> Html Msg
view model =
    Element.layout [ padding 5 ] (theWorld Fixtures.myVpc model)


update : Msg -> Model -> Model
update msg model =
    case msg of
        NodeClicked node ->
            updateSelection model node


updateSelection : Model -> Node -> Model
updateSelection model nodeSelected =
    case model of
        NothingSelected ->
            SourceNode nodeSelected

        SourceNode sourceNode ->
            Path { from = sourceNode, to = nodeSelected } 45

        Path _ _ ->
            model


theWorld : Vpc -> Model -> Element Msg
theWorld vpc model =
    case model of
        NothingSelected ->
            row
                [ width fill
                , height fill
                , spacing 10
                ]
                [ viewVpc model vpc
                , internetNode model
                ]

        SourceNode _ ->
            row
                [ width fill
                , height fill
                , spacing 10
                ]
                [ viewVpc model vpc
                , internetNode model
                ]

        Path path forPort ->
            column [ width fill, height fill ]
                [ row
                    [ width fill
                    , height fill
                    , spacing 10
                    ]
                    [ viewVpc model vpc
                    , internetNode model
                    ]
                , showConnectionInfo path forPort
                ]


showConnectionInfo path forPort =
    let
        connectivity =
            Connectivity.checkConnectivity
                { fromNode = path.from
                , toNode = path.to
                , forProtocol = Protocol.Tcp
                , overPort = forPort
                }
    in
    case connectivity of
        Connectivity.Possible ->
            text ("👍 You should be able to communicate over port " ++ String.fromInt forPort)

        Connectivity.NotPossible connectionIssues ->
            column []
                (text ("🎺 Unfortunately you cannot communicate over port " ++ String.fromInt forPort ++ " because: ")
                    :: viewIssues connectionIssues
                )


viewIssues : List Connectivity.ConnectionIssue -> List (Element msg)
viewIssues =
    List.map viewIssue


viewIssue : Connectivity.ConnectionIssue -> Element msg
viewIssue issue =
    case issue of
        Connectivity.MissingEgressRule ->
            text "Egress (Explain here why a certain security group is missing an egress rule to allow outbound traffic)"

        Connectivity.RouteTableHasNoInternetAccess ->
            text "Route table (Explain here why the route table for the source node does not allow internet traffic)"


internetNode : Model -> Element Msg
internetNode model =
    let
        attributes att =
            if isSelected Node.internet model then
                [ Background.color (rgb 0.6 0.9 0.4) ] ++ att

            else
                [ pointer, onClick (NodeClicked Node.internet) ] ++ att
    in
    el
        (attributes
            [ Border.width 2
            , Border.rounded 10
            , padding 5
            ]
        )
        (text "internet")


viewVpc : Model -> Vpc -> Element Msg
viewVpc model vpc =
    column
        [ width fill
        , height fill
        , Border.width 2
        , spacing 15
        , padding 10
        ]
        [ text ("vpc: " ++ Vpc.idAsString vpc)
        , viewSubnets model (Vpc.subnets vpc)
        ]


viewSubnets : Model -> List Subnet -> Element Msg
viewSubnets model =
    List.map (viewSubnet model) >> column [ spacing 5, width fill, height fill ]


viewSubnet : Model -> Subnet -> Element Msg
viewSubnet model subnet_ =
    column
        [ Border.width 2
        , Background.color (rgb 0 0.5 0)
        , width fill
        , padding 10
        , spacing 10
        ]
        [ text ("subnet: " ++ Subnet.idAsString subnet_)
        , viewNodes model (Subnet.nodes subnet_)
        ]


viewNodes : Model -> List Node -> Element Msg
viewNodes model =
    List.map (viewNode model) >> row [ spacing 5 ]


viewNode : Model -> Node -> Element Msg
viewNode model node_ =
    let
        attributes att =
            if isSelected node_ model then
                [ Background.color (rgb 0.6 0.9 0.4) ] ++ att

            else
                [ pointer, onClick (NodeClicked node_) ] ++ att
    in
    el
        (attributes
            [ Border.width 2
            , Border.rounded 10
            , padding 5
            ]
        )
        (text ("ec2  " ++ Node.idAsString node_))


isSelected : Node -> Model -> Bool
isSelected node model =
    case model of
        NothingSelected ->
            False

        SourceNode otherNode ->
            Node.equals node otherNode

        Path { from, to } _ ->
            List.any (Node.equals node) [ from, to ]
