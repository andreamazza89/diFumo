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
    | RouteTableCheckFailedForSource
    | NodeCannotReachTheInternet
    | NodeCannotBeReachedFromTheInternet
    | NetworkACLIngressRules
    | NetworkACLEgressRules


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
    checkSecurityGroups context
        |> combineWith (checkRouteTables context)
        |> combineWith (checkNetworkACL context)
        |> combineWith (checkInternet context)



-- Security groups


checkSecurityGroups : ConnectivityContext -> Connectivity
checkSecurityGroups context =
    checkEgressRules context
        |> combineWith (checkIngressRules context)


checkEgressRules : ConnectivityContext -> Connectivity
checkEgressRules { fromNode, toNode, forProtocol, overPort } =
    check_
        (Node.allowsEgress fromNode toNode forProtocol overPort)
        MissingEgressRule


checkIngressRules : ConnectivityContext -> Connectivity
checkIngressRules { fromNode, toNode, forProtocol, overPort } =
    check_
        (Node.allowsIngress fromNode toNode forProtocol overPort)
        MissingIngressRule



-- Route tables


checkRouteTables : ConnectivityContext -> Connectivity
checkRouteTables { fromNode, toNode } =
    checkSourceTable fromNode toNode


checkSourceTable : Node -> Node -> Connectivity
checkSourceTable fromNode toNode =
    check_
        (Node.hasRouteTo toNode fromNode)
        RouteTableCheckFailedForSource



-- Network ACL


checkNetworkACL : ConnectivityContext -> Connectivity
checkNetworkACL context =
    checkACLIngress context
        |> combineWith (checkACLEgress context)


checkACLIngress : ConnectivityContext -> Connectivity
checkACLIngress { fromNode, toNode, forProtocol, overPort } =
    check_
        (Node.aclAllowsIngress fromNode toNode forProtocol overPort)
        NetworkACLIngressRules


checkACLEgress : ConnectivityContext -> Connectivity
checkACLEgress { fromNode, toNode, forProtocol, overPort } =
    check_
        (Node.aclAllowsEgress fromNode toNode forProtocol overPort)
        NetworkACLEgressRules



-- Internet


checkInternet : ConnectivityContext -> Connectivity
checkInternet context =
    checkOutbound context
        |> combineWith (checkInbound context)


checkOutbound : ConnectivityContext -> Connectivity
checkOutbound { fromNode, toNode } =
    if Node.isInternet toNode then
        check_
            (Node.canAccessInternet fromNode)
            NodeCannotReachTheInternet

    else
        Possible


checkInbound : ConnectivityContext -> Connectivity
checkInbound { fromNode, toNode } =
    if Node.isInternet fromNode then
        check_
            (Node.canAccessInternet toNode)
            NodeCannotBeReachedFromTheInternet

    else
        Possible



-- Helpers


check_ : Bool -> ConnectionIssue -> Connectivity
check_ possible issue =
    if possible then
        Possible

    else
        NotPossible [ issue ]
