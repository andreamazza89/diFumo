module Node exposing
    ( Config
    , Node
    , aclAllowsEgress
    , aclAllowsIngress
    , allowsEgress
    , allowsIngress
    , buildEc2
    , canAccessInternet
    , equals
    , hasRouteTo
    , idAsString
    , internet
    , isInternet
    )

import IpAddress exposing (Ipv4Address)
import Node.Ec2 as Ec2 exposing (Ec2)
import Port exposing (Port)
import Protocol exposing (Protocol)
import Vpc.NetworkACL as NetworkACL exposing (NetworkACL)
import Vpc.RouteTable as RouteTable exposing (RouteTable)
import Vpc.SecurityGroup as SecurityGroup exposing (SecurityGroup)



-- Mention something here about the denormalisation. This will make it much easier to access the necessary information
-- when looking at an instance without the need to look it up from its parents.
-- The catches are:
--   1. All is (relatively) well as long as this data structure (and the whole Vpc tree) is read-only.
--   2. For testing, we should take extra care to prevent building invalid states
-- Node


type Node
    = Vpc Node_ VpcNode
    | Internet


type VpcNode
    = Ec2 Ec2


type alias Node_ =
    { ipv4Address : Ipv4Address
    , securityGroups : List SecurityGroup
    , routeTable : RouteTable
    , networkACL : NetworkACL
    }



-- Query


isInternet : Node -> Bool
isInternet node =
    case node of
        Internet ->
            True

        _ ->
            False


equals : Node -> Node -> Bool
equals node otherNode =
    case ( node, otherNode ) of
        ( Internet, Internet ) ->
            True

        ( Vpc _ vpcNode, Vpc _ otherVpcNode ) ->
            vpcNodeEquals vpcNode otherVpcNode

        _ ->
            False


vpcNodeEquals : VpcNode -> VpcNode -> Bool
vpcNodeEquals node otherNode =
    case ( node, otherNode ) of
        ( Ec2 ec2, Ec2 otherEc2 ) ->
            Ec2.equals ec2 otherEc2


ipv4Address : Node -> Ipv4Address
ipv4Address node =
    case node of
        Internet ->
            -- this is some random address; we should add this to the Internet type
            IpAddress.madeUpV4

        Vpc node_ _ ->
            node_.ipv4Address


idAsString : Node -> String
idAsString node_ =
    case node_ of
        Internet ->
            "internet"

        Vpc _ (Ec2 ec2) ->
            Ec2.idAsString ec2


allowsEgress : Node -> Node -> Protocol -> Port -> Bool
allowsEgress fromNode toNode forProtocol overPort =
    case fromNode of
        Internet ->
            -- If the source node is the internet, then there are no egress rules to check
            True

        Vpc { securityGroups } _ ->
            let
                target =
                    { ip = ipv4Address toNode
                    , forProtocol = forProtocol
                    , overPort = overPort
                    }
            in
            SecurityGroup.allowsEgress target securityGroups


allowsIngress : Node -> Node -> Protocol -> Port -> Bool
allowsIngress fromNode toNode forProtocol overPort =
    case toNode of
        Internet ->
            -- If the destination node is the internet, then there are no ingress rules to check
            True

        Vpc { securityGroups } _ ->
            let
                target =
                    { ip = ipv4Address fromNode
                    , forProtocol = forProtocol
                    , overPort = overPort
                    }
            in
            SecurityGroup.allowsIngress target securityGroups


hasRouteTo : Node -> Node -> Bool
hasRouteTo toNode fromNode =
    case fromNode of
        Internet ->
            True

        Vpc vpcNode _ ->
            RouteTable.hasRouteTo (ipv4Address toNode) vpcNode.routeTable


aclAllowsIngress : Node -> Node -> Protocol -> Port -> Bool
aclAllowsIngress fromNode toNode forProtocol overPort =
    case toNode of
        Internet ->
            True

        Vpc { networkACL } _ ->
            let
                target =
                    { ip = ipv4Address fromNode
                    , forProtocol = forProtocol
                    , overPort = overPort
                    }
            in
            NetworkACL.allowsIngress target networkACL


aclAllowsEgress : Node -> Node -> Protocol -> Port -> Bool
aclAllowsEgress fromNode toNode forProtocol overPort =
    case fromNode of
        Internet ->
            True

        Vpc { networkACL } _ ->
            let
                target =
                    { ip = ipv4Address toNode
                    , forProtocol = forProtocol
                    , overPort = overPort
                    }
            in
            NetworkACL.allowsEgress target networkACL


canAccessInternet : Node -> Bool
canAccessInternet node =
    case node of
        Internet ->
            True

        Vpc _ specificNode ->
            vpcNodeCanAccessInternet specificNode


vpcNodeCanAccessInternet : VpcNode -> Bool
vpcNodeCanAccessInternet node =
    case node of
        Ec2 ec2 ->
            Ec2.canAccessInternet ec2



-- Builders


type alias Config =
    { privateIp : Ipv4Address
    , securityGroups : List SecurityGroup
    , routeTable : RouteTable
    , networkACL : NetworkACL
    }


buildEc2 : Ec2.Config Config -> Node
buildEc2 config =
    Vpc
        { ipv4Address = config.privateIp
        , securityGroups = config.securityGroups
        , routeTable = config.routeTable
        , networkACL = config.networkACL
        }
        (Ec2 (Ec2.build config))


internet : Node
internet =
    Internet
