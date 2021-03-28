module Vpc.SecurityGroup exposing
    (  Rule_
       -- suspicious - maybe no need for Rule to be opaque..

    , SecurityGroup
    , Target
    , allowsEgress
    , allowsIngress
    , build
    , decoder
    , idAsString
    )

import Cidr exposing (Cidr)
import IpAddress exposing (Ipv4Address)
import Json.Decode as Json
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



-- Decoder


decoder : Json.Decoder SecurityGroup
decoder =
    Json.map3 build
        (Json.field "GroupId" Json.string)
        (Json.field "IpPermissions" rulesDecoder)
        (Json.field "IpPermissionsEgress" rulesDecoder)


rulesDecoder : Json.Decoder (List Rule_)
rulesDecoder =
    Json.list
        (Json.map4 Rule_
            protocolDecoder
            fromPortDecoder
            toPortDecoder
            cidrsDecoder
        )


protocolDecoder : Json.Decoder Protocol
protocolDecoder =
    Json.field "IpProtocol" Protocol.decoder


fromPortDecoder : Json.Decoder Int
fromPortDecoder =
    Json.oneOf
        [ Json.field "FromPort" Port.decoder
        , Json.succeed Port.first -- when FromPort is missing, that means all ports (at least as far as we've seen)
        ]


toPortDecoder : Json.Decoder Int
toPortDecoder =
    Json.oneOf
        [ Json.field "ToPort" Port.decoder
        , Json.succeed Port.last -- when ToPort is missing, that means all ports (at least as far as we've seen)
        ]


cidrsDecoder : Json.Decoder (List Cidr)
cidrsDecoder =
    Json.field "IpRanges" (Json.list cidrDecoder)


cidrDecoder : Json.Decoder Cidr
cidrDecoder =
    Json.field "CidrIp" Cidr.decoder
