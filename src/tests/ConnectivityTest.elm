module ConnectivityTest exposing (suite)

import Cidr
import Connectivity exposing (Connectivity, ConnectivityContext)
import Expect
import Fixtures.SecurityGroup exposing (allowAllInOut, allowNothing)
import IpAddress exposing (Ipv4Address)
import Node exposing (Node)
import Node.Ec2 as Ec2
import Port exposing (Port)
import Protocol
import Test exposing (Test, describe, test)
import Vpc.RouteTable as RouteTable exposing (RouteTable)
import Vpc.SecurityGroup exposing (SecurityGroup)


suite : Test
suite =
    describe "Connectivity"
        [ describe "Ec2 --> internet"
            [ test "ec2 can reach internet" <|
                \_ ->
                    tcpConnectivitySuccess
                        { from =
                            build
                                |> withGroup allowAllInOut
                                |> withTable internetTable
                                |> toNode
                        , to = internet
                        }
            , test "ec2 cannot reach internet with empty security group" <|
                \_ ->
                    tcpConnectivityFailure
                        { from =
                            build
                                |> withGroup allowNothing
                                |> withTable internetTable
                                |> toNode
                        , to = internet
                        }
            , test "ec2 cannot reach internet with local route table" <|
                \_ ->
                    tcpConnectivityFailure
                        { from =
                            build
                                |> withGroup allowAllInOut
                                |> withTable localTable
                                |> toNode
                        , to = internet
                        }
            ]
        , describe "internet --> Ec2"
            [ test "internet can reach ec2 with allowAll security group" <|
                \_ ->
                    tcpConnectivitySuccess
                        { from = internet
                        , to =
                            build
                                |> withGroup allowAllInOut
                                |> toNode
                        }
            , test "internet cannot reach ec2 with empty security group" <|
                \_ ->
                    tcpConnectivityFailure
                        { from = internet
                        , to =
                            build
                                |> withGroup allowNothing
                                |> toNode
                        }
            ]
        ]



-- Ec2 Fixture


build : Ec2.Config Node.Config
build =
    { id = "some-id"
    , securityGroups = []
    , privateIp = IpAddress.madeUpV4
    , routeTable = localTable
    }


withGroup : SecurityGroup -> Ec2.Config Node.Config -> Ec2.Config Node.Config
withGroup group builder =
    { builder | securityGroups = group :: builder.securityGroups }


withTable : RouteTable -> Ec2.Config Node.Config -> Ec2.Config Node.Config
withTable table builder =
    { builder | routeTable = table }


toNode : Ec2.Config Node.Config -> Node
toNode builder =
    Node.buildEc2 builder



-- end of Ec2 Fixture
-- Route Table Fixture


localTable : RouteTable
localTable =
    RouteTable.build []


internetTable : RouteTable
internetTable =
    RouteTable.build [ ( Cidr.everywhere, RouteTable.internetGateway ) ]



-- end of Route Table Fixture


internet : Node
internet =
    Node.internet



-- Connectivity assertion helpers


isPossible : Connectivity -> Expect.Expectation
isPossible =
    Connectivity.isPossible >> Expect.true "expected connectivity to be possible"


isNotPossible : Connectivity -> Expect.Expectation
isNotPossible =
    Connectivity.isPossible >> Expect.false "expected connectivity to NOT be possible"


checkTcpConnectivity : Port -> Node -> Node -> Connectivity
checkTcpConnectivity overPort from to =
    Connectivity.check
        { fromNode = from
        , toNode = to
        , forProtocol = Protocol.tcp
        , overPort = overPort
        }


tcpConnectivitySuccess : { from : Node, to : Node } -> Expect.Expectation
tcpConnectivitySuccess { from, to } =
    checkTcpConnectivity 80 from to
        |> isPossible


tcpConnectivityFailure : { from : Node, to : Node } -> Expect.Expectation
tcpConnectivityFailure { from, to } =
    checkTcpConnectivity 80 from to
        |> isNotPossible
