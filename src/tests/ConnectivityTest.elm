module ConnectivityTest exposing (suite)

import Connectivity exposing (Connectivity, ConnectivityContext)
import Expect
import Fixtures.Ec2 as Ec2
import Fixtures.RouteTable as RouteTable
import Fixtures.SecurityGroup exposing (allowAllInOut, allowNothing)
import Node exposing (Node)
import Port exposing (Port)
import Protocol
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Connectivity"
        [ describe "Ec2 --> Internet"
            [ test "ec2 can reach internet" <|
                \_ ->
                    tcpConnectivitySuccess
                        { from =
                            Ec2.build
                                |> Ec2.withGroup allowAllInOut
                                |> Ec2.withTable RouteTable.internetTable
                                |> Ec2.withPublicIp
                                |> Ec2.toNode
                        , to = internet
                        }
            , test "ec2 cannot reach internet with empty security group" <|
                \_ ->
                    tcpConnectivityFailure
                        { from =
                            Ec2.build
                                |> Ec2.withGroup allowNothing
                                |> Ec2.withTable RouteTable.internetTable
                                |> Ec2.withPublicIp
                                |> Ec2.toNode
                        , to = internet
                        }
            , test "ec2 cannot reach internet with local route table" <|
                \_ ->
                    tcpConnectivityFailure
                        { from =
                            Ec2.build
                                |> Ec2.withGroup allowAllInOut
                                |> Ec2.withTable RouteTable.localTable
                                |> Ec2.withPublicIp
                                |> Ec2.toNode
                        , to = internet
                        }
            , test "ec2 cannot reach internet without a public ip" <|
                \_ ->
                    tcpConnectivityFailure
                        { from =
                            Ec2.build
                                |> Ec2.withGroup allowAllInOut
                                |> Ec2.withTable RouteTable.internetTable
                                |> Ec2.withNoPublicIp
                                |> Ec2.toNode
                        , to = internet
                        }
            ]
        , describe "Internet --> Ec2"
            [ test "internet can reach ec2 with allowAll security group" <|
                \_ ->
                    tcpConnectivitySuccess
                        { from = internet
                        , to =
                            Ec2.build
                                |> Ec2.withGroup allowAllInOut
                                |> Ec2.withTable RouteTable.internetTable
                                |> Ec2.toNode
                        }
            , test "internet cannot reach ec2 with empty security group" <|
                \_ ->
                    tcpConnectivityFailure
                        { from = internet
                        , to =
                            Ec2.build
                                |> Ec2.withGroup allowNothing
                                |> Ec2.toNode
                        }
            ]
        ]


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
