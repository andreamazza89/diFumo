module Vpc.SecurityGroup exposing
    ( SecurityGroup
    , Target
    , allowsEgress
    , build
    )

import Cidr exposing (Cidr)
import IpAddress exposing (IpAddress)
import Port exposing (Port)
import Protocol exposing (Protocol)



-- Security Group


type SecurityGroup
    = SecurityGroup
        { description : String
        , egress : List Rule
        }


type Rule
    = Rule
        { forProtocol : Protocol
        , fromPort : Port
        , toPort : Port
        , cidr : Cidr
        }


type alias Target =
    { toIp : IpAddress
    , forProtocol : Protocol
    , overPort : Port
    }


allowsEgress : Target -> SecurityGroup -> Bool
allowsEgress target (SecurityGroup { egress }) =
    List.any (ruleMatches target) egress


ruleMatches : Target -> Rule -> Bool
ruleMatches target (Rule rule_) =
    Cidr.contains target.toIp rule_.cidr
        && (target.forProtocol == rule_.forProtocol)
        && (target.overPort >= rule_.fromPort && target.overPort <= rule_.toPort)



-- Builder


build : String -> List { fromPort : Port, toPort : Port, cidr : Cidr } -> SecurityGroup
build description egress =
    SecurityGroup
        { description = description
        , egress = List.map toRule egress
        }


toRule { fromPort, toPort, cidr } =
    Rule
        { forProtocol = Protocol.Tcp
        , fromPort = fromPort
        , toPort = toPort
        , cidr = cidr
        }
