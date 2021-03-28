module Fixtures.Ec2 exposing
    ( build
    , toNode
    , withGroup
    , withNoPublicIp
    , withPublicIp
    , withTable
    )

import Fixtures.RouteTable as RouteTable
import IpAddress
import Node exposing (Node)
import Node.Ec2 as Ec2
import Vpc.RouteTable exposing (RouteTable)
import Vpc.SecurityGroup exposing (SecurityGroup)



-- Ec2 Fixture


build : Ec2.Config Node.Config
build =
    { id = "some-id"
    , securityGroups = []
    , privateIp = IpAddress.madeUpV4
    , routeTable = RouteTable.localTable
    , publicIp = Nothing
    }


withGroup : SecurityGroup -> Ec2.Config Node.Config -> Ec2.Config Node.Config
withGroup group builder =
    { builder | securityGroups = group :: builder.securityGroups }


withTable : RouteTable -> Ec2.Config Node.Config -> Ec2.Config Node.Config
withTable table builder =
    { builder | routeTable = table }


withNoPublicIp : Ec2.Config Node.Config -> Ec2.Config Node.Config
withNoPublicIp builder =
    { builder | publicIp = Nothing }


withPublicIp : Ec2.Config Node.Config -> Ec2.Config Node.Config
withPublicIp builder =
    { builder | publicIp = Just IpAddress.madeUpV4 }


toNode : Ec2.Config Node.Config -> Node
toNode builder =
    Node.buildEc2 builder
