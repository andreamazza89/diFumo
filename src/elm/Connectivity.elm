module Connectivity exposing
    ( ConnectionIssue(..)
    , Connectivity(..)
    , ConnectivityContext
    , check
    , isPossible
    )

import Node exposing (Node)
import Port exposing (Port)
import Protocol exposing (Protocol)



-- Connectivity


type Connectivity
    = Possible
    | NotPossible (List ConnectionIssue) -- make this a nonempty list


type ConnectionIssue
    = MissingEgressRule
    | MissingIngressRule
    | RouteTableHasNoInternetAccess
    | RouteTableHasNoEntryForTargetAddress


isPossible : Connectivity -> Bool
isPossible =
    (==) Possible


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


check : ConnectivityContext -> Connectivity
check context =
    checkEgressRules context
        |> combineWith (checkRouteTable context)
        |> combineWith (checkIngressRules context)


checkRouteTable : ConnectivityContext -> Connectivity
checkRouteTable { fromNode, toNode } =
    if Node.hasRouteTo toNode fromNode then
        Possible

    else
        NotPossible [ RouteTableHasNoEntryForTargetAddress ]


checkEgressRules : ConnectivityContext -> Connectivity
checkEgressRules { fromNode, toNode, forProtocol, overPort } =
    if Node.allowsEgress fromNode toNode forProtocol overPort then
        Possible

    else
        NotPossible [ MissingEgressRule ]


checkIngressRules : ConnectivityContext -> Connectivity
checkIngressRules { fromNode, toNode, forProtocol, overPort } =
    if Node.allowsIngress fromNode toNode forProtocol overPort then
        Possible

    else
        NotPossible [ MissingIngressRule ]
