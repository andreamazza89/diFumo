module Vpc.SecurityGroup exposing
    ( Rule_
    , SecurityGroup
    , Target
    , allowsEgress
    , build
    , idAsString
    )

import Cidr exposing (Cidr)
import IpAddress exposing (Ipv4Address)
import Port exposing (Port)
import Protocol exposing (Protocol)



-- Security Group


type SecurityGroup
    = SecurityGroup
        { id : Id
        , ingress : List Rule
        , egress : List Rule
        }


type Id
    = Id String


type Rule
    = Rule Rule_


type alias Rule_ =
    { forProtocol : Protocol
    , fromPort : Port
    , toPort : Port
    , cidrs : List Cidr
    }


type alias Target =
    { toIp : Ipv4Address
    , forProtocol : Protocol
    , overPort : Port
    }


allowsEgress : Target -> SecurityGroup -> Bool
allowsEgress target (SecurityGroup { egress }) =
    List.any (ruleMatches target) egress


ruleMatches : Target -> Rule -> Bool
ruleMatches target (Rule rule_) =
    List.any (Cidr.contains target.toIp) rule_.cidrs
        && Protocol.matches target.forProtocol rule_.forProtocol
        && Port.isWithin rule_ target.overPort


idAsString : SecurityGroup -> String
idAsString (SecurityGroup { id }) =
    case id of
        Id stringId ->
            stringId



-- Builder


build : String -> List Rule_ -> List Rule_ -> SecurityGroup
build id ingress egress =
    SecurityGroup
        { id = Id id
        , ingress = List.map Rule ingress
        , egress = List.map Rule egress
        }
