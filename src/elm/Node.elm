module Node exposing
    ( Node
    , allowsEgress
    , buildEc2
    , equals
    , hasInternetRoute
    , idAsString
    , internet
    , isInternet
    )

import IpAddress exposing (Ipv4Address)
import Node.Ec2 as Ec2 exposing (Ec2)
import Port exposing (Port)
import Protocol exposing (Protocol)
import Vpc.SecurityGroup exposing (SecurityGroup)



-- Mention something here about the denormalisation. This will make it much easier to access the necessary information
-- when looking at an instance without the need to look it up from its parents.
-- The catches are:
--   1. All is (relatively) well as long as this data structure (and the whole Vpc tree) is read-only.
--   2. For testing, we should take extra care to prevent building invalid states
-- Node


type Node
    = Ec2 Ec2
    | Internet



-- Query


equals : Node -> Node -> Bool
equals node otherNode =
    case ( node, otherNode ) of
        ( Internet, Internet ) ->
            True

        ( Ec2 ec2, Ec2 otherEc2 ) ->
            Ec2.equals ec2 otherEc2

        _ ->
            False


ipv4Address : Node -> Ipv4Address
ipv4Address node =
    case node of
        Internet ->
            -- this is some random address; perhaps we should build Internet node eliciting an address form the user?
            IpAddress.madeUpV4

        Ec2 ec2 ->
            Ec2.ipAddress ec2


isInternet : Node -> Bool
isInternet node =
    case node of
        Internet ->
            True

        _ ->
            False


idAsString : Node -> String
idAsString node_ =
    case node_ of
        Ec2 ec2 ->
            Ec2.idAsString ec2

        Internet ->
            "internet"


allowsEgress : Node -> Node -> Protocol -> Port -> Bool
allowsEgress node toNode forProtocol overPort =
    case node of
        Internet ->
            -- If the source node is the internet, then security groups do not apply
            True

        Ec2 ec2 ->
            Ec2.allowsEgress
                { toIp = ipv4Address toNode
                , forProtocol = forProtocol
                , overPort = overPort
                }
                ec2


hasInternetRoute : Node -> Bool
hasInternetRoute toNode =
    case toNode of
        Internet ->
            True

        Ec2 ec2 ->
            Ec2.hasInternetRoute ec2



-- Builders


buildEc2 : Ec2.Config -> Node
buildEc2 config =
    Ec2 (Ec2.build2 config)


internet : Node
internet =
    Internet
