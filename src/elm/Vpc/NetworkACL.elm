module Vpc.NetworkACL exposing
    ( Action(..)
    , Rule
    , allowsInboundFor
    , allowsOutboundFor
    , build
    )

import Cidr exposing (Cidr)
import IpAddress exposing (Ipv4Address)
import Port exposing (Port)
import Protocol exposing (Protocol)



-- Network Access Control List


type NetworkACL
    = NetworkACL
        { ingressRules : List Rule
        , egressRules : List Rule
        }


type alias Rule =
    { cidr : Cidr
    , protocol : Protocol
    , fromPort : Port
    , toPort : Port
    , action : Action
    , ruleNumber : Int
    }


type Action
    = Allow
    | Deny


type alias Target =
    { address : Ipv4Address
    , protocol : Protocol
    , overPort : Port
    }



-- Build


build : { ingressRules : List Rule, egressRules : List Rule } -> NetworkACL
build =
    NetworkACL



-- Query


allowsInboundFor : Target -> NetworkACL -> Bool
allowsInboundFor target =
    ingressRules >> checkRules target


allowsOutboundFor : Target -> NetworkACL -> Bool
allowsOutboundFor target =
    egressRules >> checkRules target


checkRules : Target -> List Rule -> Bool
checkRules target =
    findFirstRuleMatching target
        >> toBool


ingressRules : NetworkACL -> List Rule
ingressRules (NetworkACL acl) =
    acl.ingressRules


egressRules : NetworkACL -> List Rule
egressRules (NetworkACL acl) =
    acl.egressRules


findFirstRuleMatching : Target -> List Rule -> Action
findFirstRuleMatching target =
    List.sortBy .ruleNumber
        >> List.filter (appliesTo target)
        >> List.head
        >> Maybe.map .action
        >> Maybe.withDefault Deny


appliesTo : Target -> Rule -> Bool
appliesTo target rule =
    Cidr.contains target.address rule.cidr
        && Protocol.matches target.protocol rule.protocol
        && Port.isWithin { fromPort = rule.fromPort, toPort = rule.toPort } target.overPort


toBool : Action -> Bool
toBool action =
    case action of
        Allow ->
            True

        Deny ->
            False
