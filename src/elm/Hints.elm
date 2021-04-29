module Hints exposing (forIssue)

import Connectivity


forIssue issue =
    { headline = headline issue
    , description = description issue
    , suggestedFix = fix issue
    }


headline : Connectivity.ConnectionIssue -> String
headline issue =
    case issue of
        Connectivity.MissingEgressRule ->
            "Security Group: no egress rule for destination"

        Connectivity.MissingIngressRule ->
            "Security Group: no ingress rule from source"

        Connectivity.RouteTableForSourceHasNoEntryForTargetAddress ->
            "Route Table: no route to destination"

        Connectivity.RouteTableForDestinationHasNoEntryForSourceAddress ->
            "Route Table: no route from source"

        Connectivity.NodeCannotReachTheInternet ->
            "Internet connectivity: source node cannot reach the internet"

        Connectivity.NodeCannotBeReachedFromTheInternet ->
            "Internet connectivity: source node cannot be reached from the internet"

        Connectivity.NetworkACLIngressRules ->
            "Network ACL: traffic not allowed from source"

        Connectivity.NetworkACLEgressRules ->
            "Network ACL: traffic not allowed to destination"


description : Connectivity.ConnectionIssue -> String
description issue =
    case issue of
        Connectivity.MissingEgressRule ->
            "Egress (Explain here why a certain security group is missing an egress rule to allow outbound traffic)"

        Connectivity.MissingIngressRule ->
            "None of the security groups for your destination (LABEL/NAME OF NODE) allow traffic from source (LABEL/NAME)"

        Connectivity.RouteTableForSourceHasNoEntryForTargetAddress ->
            "Route table (Explain here why the route table for the source node does have a route to the target address)"

        Connectivity.RouteTableForDestinationHasNoEntryForSourceAddress ->
            "Route table (Explain here why the route table for the target node does have a route for the source address)"

        Connectivity.NodeCannotReachTheInternet ->
            "NodeCannotReachTheInternet"

        Connectivity.NodeCannotBeReachedFromTheInternet ->
            "NodeCannotBeReachedFromTheInternet"

        Connectivity.NetworkACLIngressRules ->
            "NetworkACLIngressRules"

        Connectivity.NetworkACLEgressRules ->
            "NetworkACLEgressRules"


fix : Connectivity.ConnectionIssue -> String
fix issue =
    case issue of
        Connectivity.MissingEgressRule ->
            "XX"

        Connectivity.MissingIngressRule ->
            "Add a rule to allow <PTC> traffic over port <PRT> from the source node (LABEL/NAME) to one of the security groups for the destination node (SGID, SGID, SGID)"

        Connectivity.RouteTableForSourceHasNoEntryForTargetAddress ->
            "XX"

        Connectivity.RouteTableForDestinationHasNoEntryForSourceAddress ->
            "XX"

        Connectivity.NodeCannotReachTheInternet ->
            "XX"

        Connectivity.NodeCannotBeReachedFromTheInternet ->
            "XX"

        Connectivity.NetworkACLIngressRules ->
            "XX"

        Connectivity.NetworkACLEgressRules ->
            "XX"
