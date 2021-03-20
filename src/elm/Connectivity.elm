module Connectivity exposing (ConnectionIssue(..), Connectivity(..), checkConnectivity)

---- Connectivity

import Node exposing (Node)
import Port exposing (Port)
import Protocol exposing (Protocol)


type Connectivity
    = Possible
    | NotPossible (List ConnectionIssue) -- make this a nonempty list


type ConnectionIssue
    = MissingEgressRule
    | RouteTableHasNoInternetAccess


combineWith : Connectivity -> Connectivity -> Connectivity
combineWith conn conn_ =
    case ( conn, conn_ ) of
        ( Possible, Possible ) ->
            Possible

        ( NotPossible issues, NotPossible issues_ ) ->
            NotPossible (issues ++ issues_)

        ( NotPossible issues, Possible ) ->
            NotPossible issues

        ( Possible, NotPossible issues ) ->
            NotPossible issues



-- Checking connectivity


type alias ConnectivityContext =
    { fromNode : Node
    , toNode : Node
    , forProtocol : Protocol
    , overPort : Port
    }


checkConnectivity : ConnectivityContext -> Connectivity
checkConnectivity context =
    checkInternet context
        |> combineWith (checkEgressRules context)


checkInternet : ConnectivityContext -> Connectivity
checkInternet { fromNode, toNode } =
    if Node.isInternet toNode then
        if Node.hasInternetRoute fromNode then
            Possible

        else
            NotPossible [ RouteTableHasNoInternetAccess ]

    else
        Possible


checkEgressRules : ConnectivityContext -> Connectivity
checkEgressRules { fromNode, toNode, forProtocol, overPort } =
    if Node.allowsEgress fromNode toNode forProtocol overPort then
        Possible

    else
        NotPossible [ MissingEgressRule ]