module Main exposing (main)

import Api
import Browser exposing (Document)
import Connectivity
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Input as Input
import Node exposing (Node)
import Port exposing (Port)
import Protocol
import Vpc exposing (Vpc)
import Vpc.Subnet as Subnet exposing (Subnet)


main : Program () Model Msg
main =
    Browser.document
        { init = always ( Loading, Api.loadAllTheThings VpcsLoaded )
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


type Model
    = Loading
    | Loaded Loaded_


type alias Loaded_ =
    { vpcs : List Vpc, pathSelection : PathSelection }


type PathSelection
    = NothingSelected
    | SourceNode Node
    | Path { from : Node, to : Node } Port


type Msg
    = NodeClicked Node
    | PortTyped Port
    | NoOp
    | VpcsLoaded (Result String (List Vpc))


view : Model -> Document Msg
view model =
    { body = [ Element.layout [ padding 5 ] (theWorld model) ]
    , title = "DiFumo"
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NodeClicked node ->
            ( updateSelection node model, Cmd.none )

        PortTyped portNumber ->
            ( updatePort portNumber model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        VpcsLoaded (Ok vpcs) ->
            ( Loaded { vpcs = vpcs, pathSelection = NothingSelected }, Cmd.none )

        VpcsLoaded (Err _) ->
            ( model, Cmd.none )


updateSelection : Node -> Model -> Model
updateSelection nodeSelected model =
    case model of
        Loading ->
            Loading

        Loaded loaded ->
            case loaded.pathSelection of
                NothingSelected ->
                    Loaded { loaded | pathSelection = SourceNode nodeSelected }

                SourceNode sourceNode ->
                    Loaded { loaded | pathSelection = Path { from = sourceNode, to = nodeSelected } 80 }

                Path _ _ ->
                    Loaded { loaded | pathSelection = SourceNode nodeSelected }


updatePort : Port -> Model -> Model
updatePort portNumber model =
    case model of
        Loading ->
            Loading

        Loaded loaded ->
            case loaded.pathSelection of
                NothingSelected ->
                    Loaded loaded

                SourceNode _ ->
                    Loaded loaded

                Path path _ ->
                    Loaded { loaded | pathSelection = Path path portNumber }


portSelected : Model -> String
portSelected model =
    case model of
        Loading ->
            "80"

        Loaded loaded ->
            case loaded.pathSelection of
                NothingSelected ->
                    "80"

                SourceNode _ ->
                    "80"

                Path _ portNumber ->
                    String.fromInt portNumber


theWorld : Model -> Element Msg
theWorld model =
    case model of
        Loading ->
            Element.text "Loading..."

        Loaded loaded ->
            case loaded.pathSelection of
                NothingSelected ->
                    row
                        [ width fill
                        , height fill
                        , spacing 10
                        ]
                        [ viewVpcs loaded
                        , internetNode loaded
                        ]

                SourceNode _ ->
                    row
                        [ width fill
                        , height fill
                        , spacing 10
                        ]
                        [ viewVpcs loaded
                        , internetNode loaded
                        ]

                Path path forPort ->
                    column [ width fill, height fill ]
                        [ row
                            [ width fill
                            , height fill
                            , spacing 10
                            ]
                            [ viewVpcs loaded
                            , internetNode loaded
                            ]
                        , showConnectionInfo path forPort model
                        ]


showConnectionInfo : { a | from : Node, to : Node } -> Port -> Model -> Element Msg
showConnectionInfo path forPort model =
    let
        connectivity =
            Connectivity.check
                { fromNode = path.from
                , toNode = path.to
                , forProtocol = Protocol.Tcp
                , overPort = forPort
                }
    in
    case connectivity of
        Connectivity.Possible ->
            column []
                [ selectPort model
                , text ("👍 You should be able to communicate over port " ++ String.fromInt forPort)
                ]

        Connectivity.NotPossible connectionIssues ->
            column []
                (selectPort model
                    :: text ("🎺 Unfortunately you cannot communicate over port " ++ String.fromInt forPort ++ " because: ")
                    :: viewIssues connectionIssues
                )


selectPort : Model -> Element Msg
selectPort model =
    Input.text []
        { onChange = String.toInt >> Maybe.map PortTyped >> Maybe.withDefault NoOp
        , text = portSelected model
        , placeholder = Nothing
        , label = Input.labelHidden "select-port"
        }


viewIssues : List Connectivity.ConnectionIssue -> List (Element Msg)
viewIssues =
    List.map viewIssue


viewIssue : Connectivity.ConnectionIssue -> Element Msg
viewIssue issue =
    case issue of
        Connectivity.MissingEgressRule ->
            text "Egress (Explain here why a certain security group is missing an egress rule to allow outbound traffic)"

        Connectivity.RouteTableHasNoInternetAccess ->
            text "Route table (Explain here why the route table for the source node does not allow internet traffic)"


internetNode : Loaded_ -> Element Msg
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


viewVpcs : Loaded_ -> Element Msg
viewVpcs model =
    List.map (viewVpc model) model.vpcs
        |> column [ width fill, height fill ]


viewVpc : Loaded_ -> Vpc -> Element Msg
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


viewSubnets : Loaded_ -> List Subnet -> Element Msg
viewSubnets model =
    List.map (viewSubnet model) >> column [ spacing 5, width fill, height fill ]


viewSubnet : Loaded_ -> Subnet -> Element Msg
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


viewNodes : Loaded_ -> List Node -> Element Msg
viewNodes model =
    List.map (viewNode model) >> row [ spacing 5 ]


viewNode : Loaded_ -> Node -> Element Msg
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


isSelected : Node -> Loaded_ -> Bool
isSelected node model =
    case model.pathSelection of
        NothingSelected ->
            False

        SourceNode otherNode ->
            Node.equals node otherNode

        Path { from, to } _ ->
            List.any (Node.equals node) [ from, to ]
