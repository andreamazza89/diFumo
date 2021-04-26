module Main exposing (main)

import Api
import Api.Ports as Ports exposing (AwsCredentials)
import Browser exposing (Document)
import Connectivity
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Colors as Colors
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Icon.Cloud as Cloud
import Element.Icon.Database as Database
import Element.Icon.LoadBalancer as LoadBalancer
import Element.Icon.Server as Server
import Element.Input as Input
import Element.Scale as Scale exposing (edges)
import Element.Text as Text
import Html.Attributes
import Node exposing (Node)
import Port exposing (Port)
import Protocol
import Utils.NonEmptyList as NonEmptyList exposing (NonEmptyList)
import Vpc exposing (Vpc)
import Vpc.Subnet as Subnet exposing (Subnet)


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Model
    = WaitingForCredentials AwsCredentials
    | Loading AwsCredentials
    | Loaded Loaded_ AwsCredentials


type alias Loaded_ =
    { otherVpcs : List Vpc
    , vpcSelected : Vpc
    , pathSelection : PathSelection
    , portSelected : String
    }


type PathSelection
    = NothingSelected
    | SourceNode Node
    | Path { from : Node, to : Node } Port


type Msg
    = NodeClicked Node
    | PortTyped String
    | NoOp
    | ReceivedVpcs (Result String (NonEmptyList Vpc))
    | SubmitCredentialsClicked
    | RefreshClicked
    | AccessKeyIdTyped String
    | SecretAccessKeyTyped String
    | SessionTokenTyped String


init : () -> ( Model, Cmd msg )
init _ =
    ( WaitingForCredentials Ports.emptyCredentials, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Ports.awsDataReceived (Api.decodeAwsData >> ReceivedVpcs)


view : Model -> Document Msg
view model =
    { body = [ Element.layout [ width fill, height fill ] (theWorld model) ]
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

        ReceivedVpcs (Ok vpcs) ->
            ( Loaded
                { vpcSelected = NonEmptyList.head vpcs
                , otherVpcs = NonEmptyList.tail vpcs
                , pathSelection = NothingSelected
                , portSelected = Port.https |> Port.toString
                }
                (credentials model)
            , Cmd.none
            )

        ReceivedVpcs (Err _) ->
            ( model, Cmd.none )

        SubmitCredentialsClicked ->
            ( Loading (credentials model), Ports.fetchAwsData (credentials model) )

        RefreshClicked ->
            ( Loading (credentials model), Ports.fetchAwsData (credentials model) )

        AccessKeyIdTyped id ->
            ( updateAccessKeyId id model, Cmd.none )

        SecretAccessKeyTyped accessKey ->
            ( updateSecretAccessKey accessKey model, Cmd.none )

        SessionTokenTyped token ->
            ( updateSessionToken token model, Cmd.none )


updateSelection : Node -> Model -> Model
updateSelection nodeSelected model =
    case model of
        Loading creds ->
            Loading creds

        WaitingForCredentials creds ->
            WaitingForCredentials creds

        Loaded loaded creds ->
            case loaded.pathSelection of
                NothingSelected ->
                    Loaded { loaded | pathSelection = SourceNode nodeSelected } creds

                SourceNode sourceNode ->
                    Loaded { loaded | pathSelection = Path { from = sourceNode, to = nodeSelected } 80 } creds

                Path _ _ ->
                    Loaded { loaded | pathSelection = SourceNode nodeSelected } creds


updatePort : String -> Model -> Model
updatePort portNumber model =
    case model of
        Loading creds ->
            Loading creds

        WaitingForCredentials creds ->
            WaitingForCredentials creds

        Loaded loaded creds ->
            Loaded { loaded | portSelected = portNumber } creds


updateAccessKeyId : String -> Model -> Model
updateAccessKeyId id model =
    case model of
        Loading creds ->
            Loading creds

        WaitingForCredentials creds ->
            WaitingForCredentials { creds | accessKeyId = id }

        Loaded loaded creds ->
            Loaded loaded creds


updateSecretAccessKey : String -> Model -> Model
updateSecretAccessKey key model =
    case model of
        Loading creds ->
            Loading creds

        WaitingForCredentials creds ->
            WaitingForCredentials { creds | secretAccessKey = key }

        Loaded loaded creds ->
            Loaded loaded creds


updateSessionToken : String -> Model -> Model
updateSessionToken token model =
    case model of
        Loading creds ->
            Loading creds

        WaitingForCredentials creds ->
            WaitingForCredentials { creds | sessionToken = token }

        Loaded loaded creds ->
            Loaded loaded creds


credentials : Model -> AwsCredentials
credentials model =
    case model of
        Loading creds ->
            creds

        WaitingForCredentials creds ->
            creds

        Loaded _ creds ->
            creds


portSelectedDelete : Model -> String
portSelectedDelete model =
    case model of
        Loading _ ->
            "80"

        WaitingForCredentials _ ->
            "80"

        Loaded loaded _ ->
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
        Loading _ ->
            column
                [ width fill
                ]
                [ Element.text "Loading...", refreshButton ]

        WaitingForCredentials creds ->
            column [ width fill, spacing 30, padding 20 ]
                [ text "Please enter your aws credentials below"
                , Input.text []
                    { onChange = AccessKeyIdTyped
                    , text = creds.accessKeyId
                    , placeholder = Nothing
                    , label = Input.labelAbove [] (text "Access key")
                    }
                , Input.text []
                    { onChange = SecretAccessKeyTyped
                    , text = creds.secretAccessKey
                    , placeholder = Nothing
                    , label = Input.labelAbove [] (text "Secret Access key")
                    }
                , Input.text []
                    { onChange = SessionTokenTyped
                    , text = creds.sessionToken
                    , placeholder = Nothing
                    , label = Input.labelAbove [] (text "Session token")
                    }
                , Input.button []
                    { onPress = Just SubmitCredentialsClicked
                    , label = text "Submit"
                    }
                ]

        Loaded loaded _ ->
            loadedView loaded loaded


loadedView : Loaded_ -> Loaded_ -> Element Msg
loadedView model loaded =
    column
        [ width fill
        , height fill
        ]
        [ topBar
        , row
            [ width fill
            , height fill
            , padding Scale.small
            , spacing Scale.medium
            ]
            [ subnets model loaded.vpcSelected
            , connections model
            ]
        ]


subnets : Loaded_ -> Vpc -> Element Msg
subnets model vpc =
    row
        [ width (fillPortion 7)
        , height fill
        , spacing Scale.medium
        ]
        [ privateSubnets model vpc
        , publicSubnets model vpc
        ]


privateSubnets : Loaded_ -> Vpc -> Element Msg
privateSubnets model vpc =
    column
        [ width fill
        , height fill
        , spacing Scale.medium
        ]
        [ subnetsHeader "Private subnets"
        , viewSubnets2 model (Vpc.privateSubnets vpc)
        ]


viewSubnets2 : Loaded_ -> List Subnet -> Element Msg
viewSubnets2 model =
    List.map (viewSubnet2 model)
        >> column
            [ width fill
            , height fill
            , scrollbarY
            , spacing Scale.medium
            ]


viewSubnet2 : Loaded_ -> Subnet -> Element Msg
viewSubnet2 model subnet =
    column
        [ width fill
        , Border.width 1
        , Border.rounded 10
        , Background.color Colors.lightGrey
        ]
        [ viewNodes2 model (Subnet.nodes subnet)
        , subnetName subnet
        ]


viewNodes2 : Loaded_ -> List Node -> Element Msg
viewNodes2 model nodes =
    if List.isEmpty nodes then
        Text.text [ padding Scale.small ] "this subnet is empty"

    else
        List.map (viewNode2 model) nodes
            |> wrappedRow
                [ spacing Scale.small
                , height fill
                , padding Scale.small
                ]


viewNode2 : Loaded_ -> Node -> Element Msg
viewNode2 model node =
    column
        [ Border.width 1
        , Border.rounded 5
        , padding Scale.verySmall
        , width (px Scale.veryLarge)
        , height (px Scale.veryLarge)
        , nodeBackground model node
        , mouseOver [ Background.color Colors.olive ]
        , htmlAttribute (Html.Attributes.class "node")
        , onClick (NodeClicked node)
        , pointer
        ]
        [ nodeLabel node
        , nodeIcon node
        , nodeName node
        ]


nodeBackground : Loaded_ -> Node -> Attr decorative msg
nodeBackground model node =
    if isSelected node model then
        Background.color Colors.olive

    else
        Background.color Colors.white


nodeLabel : Node -> Element msg
nodeLabel =
    Node.label >> Text.nodeLabel [ centerX ]


nodeIcon : Node -> Element msg
nodeIcon node =
    case Node.tipe node of
        Node.InternetNode ->
            el [ centerX, centerY ] Cloud.icon

        Node.Ec2Node ->
            el [ centerX, centerY ] Server.icon

        Node.RdsNode ->
            el [ centerX, centerY ] Database.icon

        Node.EcsTaskNode ->
            el [ centerX, centerY ] Server.icon

        Node.LoadBalancerNode ->
            el [ centerX, centerY ] LoadBalancer.icon


nodeName : Node -> Element msg
nodeName node =
    let
        name =
            Node.name node

        alignment =
            if String.length name < 12 then
                centerX

            else
                alignLeft
    in
    case Node.tipe node of
        Node.InternetNode ->
            none

        _ ->
            Text.smallText [ Background.color Colors.white, alignment ] name


subnetName : Subnet -> Element msg
subnetName subnet =
    el
        [ width fill
        , Border.widthEach { edges | top = 1 }
        ]
        (Text.smallText [ alignRight, padding Scale.verySmall ] (Subnet.name subnet))


subnetsHeader : String -> Element msg
subnetsHeader =
    Text.header
        [ alignTop
        , centerX
        , Border.widthEach { edges | bottom = 2 }
        , Border.dashed
        , padding Scale.medium
        ]


publicSubnets : Loaded_ -> Vpc -> Element Msg
publicSubnets model vpc =
    column [ width fill, height fill, spacing Scale.medium ]
        [ subnetsHeader "Public subnets"
        , viewSubnets2 model (Vpc.publicSubnets vpc)
        ]


connections : Loaded_ -> Element Msg
connections model =
    column
        [ width (fillPortion 2)
        , height fill
        , spacing Scale.large
        ]
        [ internet model
        , connectivityPanel model
        ]


internet : Loaded_ -> Element Msg
internet model =
    row
        [ centerX
        , spacing Scale.medium
        ]
        [ viewNode2 model Node.internet
        , Text.text [] "42 . 42 . 42. 42"
        ]


connectivityPanel : Loaded_ -> Element Msg
connectivityPanel ({ pathSelection, portSelected } as loaded) =
    column
        [ Background.color Colors.lightGrey
        , spacing Scale.large
        , padding Scale.medium
        , width fill
        , height fill
        , Border.widthEach { edges | left = 2, top = 2 }
        , Border.dashed
        ]
        [ sourceNode2 pathSelection
        , destinationNode2 pathSelection
        , selectPort2 portSelected
        , selectProtocol
        , connectivityIssues loaded
        ]


sourceNode2 : PathSelection -> Element msg
sourceNode2 selection =
    case selection of
        NothingSelected ->
            readOnlyNodeField "Source node" Nothing

        SourceNode node ->
            readOnlyNodeField "Source node" (Just node)

        Path { from } _ ->
            readOnlyNodeField "Source node" (Just from)


destinationNode2 selection =
    case selection of
        NothingSelected ->
            readOnlyNodeField "Destination node" Nothing

        SourceNode _ ->
            readOnlyNodeField "Destination node" Nothing

        Path { to } _ ->
            readOnlyNodeField "Destination node" (Just to)


readOnlyNodeField label node =
    column [ spacing Scale.small ]
        [ Text.fieldLabel [] label
        , Maybe.map
            (\n ->
                row [ spacing Scale.verySmall ]
                    [ Text.nodeLabel [] (Node.label n)
                    , Text.smallText [] ("(" ++ Node.name n ++ ")")
                    ]
            )
            node
            |> Maybe.withDefault (Text.smallText [] "Please select a node")
        ]


selectPort2 : String -> Element Msg
selectPort2 portSelected =
    column [ spacing Scale.small ]
        [ Text.fieldLabel [] "Port"
        , Input.text [ Background.color Colors.lightGrey ]
            { onChange = PortTyped
            , text = portSelected
            , placeholder = Nothing
            , label = Input.labelHidden "select-port"
            }
        ]


selectProtocol =
    column [ spacing Scale.small ]
        [ Text.fieldLabel [] "Protocol"
        , Text.smallText [] "TCP"
        ]


connectivityIssues { pathSelection, portSelected } =
    case ( pathSelection, Port.fromString portSelected ) of
        ( Path path _, Just port_ ) ->
            showConnectionInfo path port_

        ( _, _ ) ->
            none



--case loaded.pathSelection of
--    NothingSelected ->
--        column [ width fill, height fill, spacing 30 ]
--            [ topBar
--            , row
--                [ width fill
--                , height fill
--                , spacing 10
--                ]
--                [ viewVpcs loaded
--                , internetNode loaded
--                ]
--            ]
--
--    SourceNode _ ->
--        column [ width fill, height fill, spacing 30 ]
--            [ topBar
--            , row
--                [ width fill
--                , height fill
--                , spacing 10
--                ]
--                [ viewVpcs loaded
--                , internetNode loaded
--                ]
--            ]
--
--    Path path forPort ->
--        column [ width fill, height fill, spacing 30 ]
--            [ topBar
--            , row
--                [ width fill
--                , height fill
--                , spacing 10
--                ]
--                [ viewVpcs loaded
--                , internetNode loaded
--                ]
--            , showConnectionInfo path forPort model
--            ]


topBar : Element Msg
topBar =
    row
        [ width fill
        , Background.color Colors.darkGrey
        , padding Scale.large
        , spacing Scale.large
        ]
        [ refreshButton
        , selectVpc
        , selectRegion
        ]


refreshButton : Element Msg
refreshButton =
    Input.button [] { onPress = Just RefreshClicked, label = text "Refresh" }


selectVpc : Element msg
selectVpc =
    text "vpc selection"


selectRegion : Element msg
selectRegion =
    text "region selection"


showConnectionInfo : { a | from : Node, to : Node } -> Port -> Element Msg
showConnectionInfo path forPort =
    let
        connectivity =
            Connectivity.check
                { fromNode = path.from
                , toNode = path.to
                , forProtocol = Protocol.tcp
                , overPort = forPort
                }
    in
    case connectivity of
        Connectivity.Possible ->
            column [ width fill ]
                [ Text.text [ Font.size 44, centerX ] "👍"
                ]

        Connectivity.NotPossible connectionIssues ->
            column [ spacing Scale.medium ]
                (Text.header [] "🎺 Connectivity issues "
                    :: paragraph [] [ Text.smallText [] "Below is a list of reasons why the two nodes selected cannot communicate." ]
                    :: viewIssues connectionIssues
                )


selectPort : Model -> Element Msg
selectPort model =
    Input.text []
        { onChange = PortTyped
        , text = portSelectedDelete model
        , placeholder = Nothing
        , label = Input.labelHidden "select-port"
        }


viewIssues : List Connectivity.ConnectionIssue -> List (Element Msg)
viewIssues =
    List.map viewIssue


viewIssue : Connectivity.ConnectionIssue -> Element Msg
viewIssue issue =
    paragraph
        [ Border.width 1
        , Border.rounded 5
        , padding Scale.small
        , Background.color Colors.olive
        ]
        [ column [ spacing Scale.small ] (viewIssue_ issue) ]


viewIssue_ issue =
    case issue of
        Connectivity.MissingEgressRule ->
            [ issueHeadline "Security Group: no egress rule for destination"
            , Text.smallText [] "Egress (Explain here why a certain security group is missing an egress rule to allow outbound traffic)"
            ]

        Connectivity.MissingIngressRule ->
            [ issueHeadline "Security Group: no ingress rule from source"
            , Text.smallText [] "Ingress (Explain here why a certain security group is missing an ingress rule to allow outbound traffic)"
            ]

        Connectivity.RouteTableForSourceHasNoEntryForTargetAddress ->
            [ issueHeadline "Route Table: no route to destination"
            , Text.smallText [] "Route table (Explain here why the route table for the source node does have a route to the target address)"
            ]

        Connectivity.RouteTableForDestinationHasNoEntryForSourceAddress ->
            [ issueHeadline "Route Table: no route from source"
            , Text.smallText [] "Route table (Explain here why the route table for the target node does have a route for the source address)"
            ]

        Connectivity.NodeCannotReachTheInternet ->
            [ issueHeadline "Internet connectivity: source node cannot reach the internet"
            , Text.smallText [] "NodeCannotReachTheInternet"
            ]

        Connectivity.NodeCannotBeReachedFromTheInternet ->
            [ issueHeadline "Internet connectivity: source node cannot be reached from the internet"
            , Text.smallText [] "NodeCannotBeReachedFromTheInternet"
            ]

        Connectivity.NetworkACLIngressRules ->
            [ issueHeadline "Network ACL: traffic not allowed from source"
            , Text.smallText [] "NetworkACLIngressRules"
            ]

        Connectivity.NetworkACLEgressRules ->
            [ issueHeadline "Network ACL: traffic not allowed to destination"
            , Text.smallText [] "NetworkACLEgressRules"
            ]


issueHeadline : String -> Element msg
issueHeadline =
    Text.smallText [ Font.bold ]


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
    List.map (viewVpc model) model.otherVpcs
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
