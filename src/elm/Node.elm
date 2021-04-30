module Node exposing
    ( Config
    , Node
    , NodeType(..)
    , aclAllowsEgress
    , aclAllowsIngress
    , allowsEgress
    , allowsIngress
    , buildEc2
    , buildEcsTask
    , buildLoadBalancer
    , buildRds
    , canAccessInternet
    , equals
    , hasRouteTo
    , idAsString
    , internet
    , isInternet
    , label
    , name
    , routeTable
    , securityGroups
    , tipe
    )

import IpAddress exposing (Ipv4Address)
import Node.Ec2 as Ec2 exposing (Ec2)
import Node.EcsTask as EcsTask exposing (EcsTask)
import Node.LoadBalancer as LoadBalancer exposing (LoadBalancer)
import Node.Rds as Rds exposing (Rds)
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
    | Rds Rds
    | EcsTask EcsTask
    | LoadBalancer LoadBalancer


type alias Node_ =
    { ipv4Address : Ipv4Address
    , securityGroups : List SecurityGroup
    , routeTable : RouteTable
    , networkACL : NetworkACL
    }


type NodeType
    = InternetNode
    | Ec2Node
    | RdsNode
    | EcsTaskNode
    | LoadBalancerNode



-- Query


tipe : Node -> NodeType
tipe node =
    case node of
        Internet ->
            InternetNode

        Vpc _ vpcNode ->
            case vpcNode of
                Ec2 _ ->
                    Ec2Node

                Rds _ ->
                    RdsNode

                EcsTask _ ->
                    EcsTaskNode

                LoadBalancer _ ->
                    LoadBalancerNode


name : Node -> String
name node =
    case node of
        Internet ->
            "Internet"

        Vpc _ vpcNode ->
            vpcNodeName vpcNode


vpcNodeName : VpcNode -> String
vpcNodeName vpcNode =
    case vpcNode of
        Ec2 ec2 ->
            Ec2.name ec2

        Rds rds ->
            Rds.name rds

        EcsTask ecsTask ->
            EcsTask.name ecsTask

        LoadBalancer loadBalancer ->
            LoadBalancer.name loadBalancer


label : Node -> String
label node =
    case tipe node of
        InternetNode ->
            "INTERNET"

        Ec2Node ->
            "EC2"

        RdsNode ->
            "RDS"

        EcsTaskNode ->
            "ECS"

        LoadBalancerNode ->
            "LB"


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

        ( Rds rds, Rds otherRds ) ->
            Rds.equals rds otherRds

        ( EcsTask ecs, EcsTask otherEcs ) ->
            EcsTask.equals ecs otherEcs

        ( LoadBalancer lb, LoadBalancer otherLb ) ->
            LoadBalancer.equals lb otherLb

        ( _, _ ) ->
            False


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

        Vpc _ (Rds rds) ->
            Rds.idAsString rds

        Vpc _ (EcsTask ecs) ->
            EcsTask.idAsString ecs

        Vpc _ (LoadBalancer lb) ->
            LoadBalancer.idAsString lb


allowsEgress : Node -> Node -> Protocol -> Port -> Bool
allowsEgress fromNode toNode forProtocol overPort =
    case fromNode of
        Internet ->
            -- If the source node is the internet, then there are no egress rules to check
            True

        Vpc node _ ->
            let
                target =
                    { ip = ipv4Address toNode
                    , forProtocol = forProtocol
                    , overPort = overPort
                    }
            in
            SecurityGroup.allowsEgress target node.securityGroups


allowsIngress : Node -> Node -> Protocol -> Port -> Bool
allowsIngress fromNode toNode forProtocol overPort =
    case toNode of
        Internet ->
            -- If the destination node is the internet, then there are no ingress rules to check
            True

        Vpc node _ ->
            let
                target =
                    { ip = ipv4Address fromNode
                    , forProtocol = forProtocol
                    , overPort = overPort
                    }
            in
            SecurityGroup.allowsIngress target node.securityGroups


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

        Rds rds ->
            Rds.canAccessInternet rds

        EcsTask ecsTask ->
            EcsTask.canAccessInternet ecsTask

        LoadBalancer loadBalancer ->
            LoadBalancer.canAccessInternet loadBalancer


securityGroups : Node -> List SecurityGroup
securityGroups node =
    case node of
        Internet ->
            []

        Vpc node_ _ ->
            node_.securityGroups


routeTable : Node -> Maybe RouteTable
routeTable node =
    case node of
        Internet ->
            Nothing

        Vpc node_ _ ->
            Just node_.routeTable



-- Builders


type alias Config a =
    { a
        | privateIp : Ipv4Address
        , securityGroups : List SecurityGroup
        , routeTable : RouteTable
        , networkACL : NetworkACL
    }


buildEc2 : Config (Ec2.Config a) -> Node
buildEc2 config =
    Vpc (buildVpcNode config) (Ec2 (Ec2.build config))


buildRds : Config (Rds.Config a) -> Node
buildRds config =
    Vpc (buildVpcNode config) (Rds (Rds.build config))


buildEcsTask : Config (EcsTask.Config a) -> Node
buildEcsTask config =
    Vpc (buildVpcNode config) (EcsTask (EcsTask.build config))


buildLoadBalancer : Config (LoadBalancer.Config a) -> Node
buildLoadBalancer config =
    Vpc (buildVpcNode config) (LoadBalancer (LoadBalancer.build config))


buildVpcNode : Config a -> Node_
buildVpcNode config =
    { ipv4Address = config.privateIp
    , securityGroups = config.securityGroups
    , routeTable = config.routeTable
    , networkACL = config.networkACL
    }


internet : Node
internet =
    Internet
