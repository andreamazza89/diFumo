module Fixtures.Ec2 exposing
    ( builder
    , toNode
    , withGroup
    , withNetworkACL
    , withNoPublicIp
    , withPublicIp
    , withTable
    )

import Fixtures.NetworkACL as NetworkACL
import Fixtures.RouteTable as RouteTable
import IpAddress
import Node exposing (Node)
import Node.Ec2 as Ec2
import Vpc.NetworkACL exposing (NetworkACL)
import Vpc.RouteTable exposing (RouteTable)
import Vpc.SecurityGroup exposing (SecurityGroup)



-- Ec2 Fixture


builder =
    { id = "some-id"
    , securityGroups = []
    , privateIp = IpAddress.madeUpV4
    , routeTable = RouteTable.localTable
    , publicIp = Nothing
    , networkACL = NetworkACL.allowAll
    , tags = []
    }


withGroup : SecurityGroup -> Node.Config (Ec2.Config a) -> Node.Config (Ec2.Config a)
withGroup group builder_ =
    { builder_ | securityGroups = group :: builder_.securityGroups }


withTable : RouteTable -> Node.Config (Ec2.Config a) -> Node.Config (Ec2.Config a)
withTable table builder_ =
    { builder_ | routeTable = table }


withNetworkACL : NetworkACL -> Node.Config (Ec2.Config a) -> Node.Config (Ec2.Config a)
withNetworkACL acl builder_ =
    { builder_ | networkACL = acl }


withNoPublicIp : Node.Config (Ec2.Config a) -> Node.Config (Ec2.Config a)
withNoPublicIp builder_ =
    { builder_ | publicIp = Nothing }


withPublicIp : Node.Config (Ec2.Config a) -> Node.Config (Ec2.Config a)
withPublicIp builder_ =
    { builder_ | publicIp = Just IpAddress.madeUpV4 }


toNode : Node.Config (Ec2.Config a) -> Node
toNode builder_ =
    Node.buildEc2 builder_
