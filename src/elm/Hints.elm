module Hints exposing (forIssue)

import Connectivity exposing (ConnectivityContext)
import Node exposing (Node)
import Port
import Protocol
import Region exposing (Region)
import Vpc.RouteTable as RouteTable
import Vpc.SecurityGroup as SecurityGroup


type alias Hints =
    { headline : String
    , description : String
    , suggestedFix : String
    , link : String
    }


forIssue : Region -> ConnectivityContext -> Connectivity.ConnectionIssue -> Hints
forIssue region context issue =
    { headline = headline issue
    , description = description context issue
    , suggestedFix = fix context issue
    , link = link region context issue
    }


headline : Connectivity.ConnectionIssue -> String
headline issue =
    case issue of
        Connectivity.MissingEgressRule ->
            "Security Group: no egress rule for destination"

        Connectivity.MissingIngressRule ->
            "Security Group: no ingress rule for source"

        Connectivity.RouteTableCheckFailedForSource ->
            "Route Table: no route to destination"

        Connectivity.NodeCannotReachTheInternet ->
            "Internet connectivity: source node cannot reach the internet"

        Connectivity.NodeCannotBeReachedFromTheInternet ->
            "Internet connectivity: source node cannot be reached from the internet"

        Connectivity.NetworkACLIngressRules ->
            "Network ACL: traffic not allowed from source"

        Connectivity.NetworkACLEgressRules ->
            "Network ACL: traffic not allowed to destination"


description : ConnectivityContext -> Connectivity.ConnectionIssue -> String
description context issue =
    case issue of
        Connectivity.MissingEgressRule ->
            "None of the security groups for your source " ++ nodeInfo context.fromNode ++ " allow traffic to destination " ++ nodeInfo context.toNode

        Connectivity.MissingIngressRule ->
            "None of the security groups for your destination " ++ nodeInfo context.toNode ++ " allow traffic from source " ++ nodeInfo context.fromNode

        Connectivity.RouteTableCheckFailedForSource ->
            "There is no route from your source " ++ nodeInfo context.fromNode ++ " to your destination " ++ nodeInfo context.toNode

        Connectivity.NodeCannotReachTheInternet ->
            "NodeCannotReachTheInternet"

        Connectivity.NodeCannotBeReachedFromTheInternet ->
            "NodeCannotBeReachedFromTheInternet"

        Connectivity.NetworkACLIngressRules ->
            "NetworkACLIngressRules"

        Connectivity.NetworkACLEgressRules ->
            "NetworkACLEgressRules"


fix : ConnectivityContext -> Connectivity.ConnectionIssue -> String
fix context issue =
    case issue of
        Connectivity.MissingEgressRule ->
            "Add a rule to allow outbound " ++ protocol context ++ " traffic over port " ++ port_ context ++ " to the destination node " ++ nodeInfo context.toNode ++ " on one of the security groups for the source node (" ++ securityGroups context.fromNode ++ ")"

        Connectivity.MissingIngressRule ->
            "Add a rule to allow inbound " ++ protocol context ++ " traffic over port " ++ port_ context ++ " from the source node " ++ nodeInfo context.fromNode ++ " on one of the security groups for the destination node (" ++ securityGroups context.toNode ++ ")"

        Connectivity.RouteTableCheckFailedForSource ->
            if Node.isInternet context.fromNode then
                "If you need internet connectivity for a node that is in private subnet, you can either do so by adding a Load Balancer or making the subnet public. The latter solution involves updating the route table " ++ routeTable context.toNode ++ " for the subnet your destination node " ++ nodeInfo context.toNode ++ " is in"

            else if Node.isInternet context.toNode then
                "If you need internet connectivity for a node that is in private subnet, you can either do so via a NAT Gateway (for outbound traffic only) or by making the subnet public. Both solutions involve updating the route table " ++ routeTable context.fromNode ++ " for the subnet your source node " ++ nodeInfo context.fromNode ++ " is in"

            else
                "You might need to add a rule to the route table " ++ routeTable context.fromNode ++ " for the subnet your source node is in that routes traffic to the destination " ++ nodeInfo context.toNode

        Connectivity.NodeCannotReachTheInternet ->
            "WIP: imagine a very useful potential fix"

        Connectivity.NodeCannotBeReachedFromTheInternet ->
            "WIP: imagine a very useful potential fix"

        Connectivity.NetworkACLIngressRules ->
            "WIP: imagine a very useful potential fix"

        Connectivity.NetworkACLEgressRules ->
            "WIP: imagine a very useful potential fix"


link : Region -> ConnectivityContext -> Connectivity.ConnectionIssue -> String
link region context issue =
    -- should probably use Url.Builder
    case issue of
        Connectivity.MissingEgressRule ->
            "https://" ++ Region.id region ++ ".console.aws.amazon.com/ec2/v2/home?region=" ++ Region.id region ++ "#SecurityGroup:groupId=" ++ firstSecurityGroup context.fromNode

        Connectivity.MissingIngressRule ->
            "https://" ++ Region.id region ++ ".console.aws.amazon.com/ec2/v2/home?region=" ++ Region.id region ++ "#SecurityGroup:groupId=" ++ firstSecurityGroup context.toNode

        Connectivity.RouteTableCheckFailedForSource ->
            if Node.isInternet context.fromNode then
                "https://" ++ Region.id region ++ ".console.aws.amazon.com/vpc/home?region=" ++ Region.id region ++ "#RouteTables:routeTableId=" ++ routeTable context.toNode

            else
                "https://" ++ Region.id region ++ ".console.aws.amazon.com/vpc/home?region=" ++ Region.id region ++ "#RouteTables:routeTableId=" ++ routeTable context.fromNode

        Connectivity.NodeCannotReachTheInternet ->
            "XX"

        Connectivity.NodeCannotBeReachedFromTheInternet ->
            "XX"

        Connectivity.NetworkACLIngressRules ->
            "XX"

        Connectivity.NetworkACLEgressRules ->
            "XX"



-- Helpers


protocol : ConnectivityContext -> String
protocol =
    .forProtocol >> Protocol.toString


port_ : ConnectivityContext -> String
port_ =
    .overPort >> Port.toString


nodeInfo : Node -> String
nodeInfo node =
    "(" ++ Node.label node ++ "/" ++ Node.name node ++ ")"


securityGroups : Node -> String
securityGroups =
    securityGroups_ >> String.join ", "


firstSecurityGroup : Node -> String
firstSecurityGroup =
    securityGroups_
        >> List.head
        >> Maybe.map (\group -> "#SecurityGroup:groupId=" ++ group)
        >> Maybe.withDefault ""


securityGroups_ : Node -> List String
securityGroups_ =
    Node.securityGroups
        >> List.map SecurityGroup.idAsString


routeTable : Node -> String
routeTable =
    Node.routeTable
        >> Maybe.map (\rt -> "(" ++ RouteTable.idAsString rt ++ ")")
        >> Maybe.withDefault ""
