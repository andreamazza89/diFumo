module Vpc.SecurityGroup exposing
    (  Rule_
       -- suspicious - maybe no need for Rule to be opaque..

    , SecurityGroup
    , Target
    , allowsEgress
    , allowsIngress
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
    { ip : Ipv4Address
    , forProtocol : Protocol
    , overPort : Port
    }


allowsEgress : Target -> List SecurityGroup -> Bool
allowsEgress target =
    List.any (allowsEgress_ target)


allowsEgress_ : Target -> SecurityGroup -> Bool
allowsEgress_ target (SecurityGroup { egress }) =
    List.any (ruleMatches target) egress


allowsIngress : Target -> List SecurityGroup -> Bool
allowsIngress target =
    List.any (allowsIngress_ target)


allowsIngress_ : Target -> SecurityGroup -> Bool
allowsIngress_ target (SecurityGroup { ingress }) =
    List.any (ruleMatches target) ingress


ruleMatches : Target -> Rule -> Bool
ruleMatches target (Rule rule_) =
    List.any (Cidr.contains target.ip) rule_.cidrs
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
