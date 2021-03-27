module ConnectivityTest exposing (suite)

import Connectivity exposing (Connectivity, ConnectivityContext)
import Expect
import Fixtures.SecurityGroup exposing (allowAllInOut, allowNothing)
import IpAddress exposing (Ipv4Address)
import Node exposing (Node)
import Node.Ec2 as Ec2
import Port exposing (Port)
import Protocol
import Test exposing (Test, describe, test)
import Vpc.SecurityGroup exposing (SecurityGroup)


suite : Test
suite =
    describe "Connectivity"
        [ describe "Ec2 --> internet"
            [ test "ec2 can reach internet with allowAll security group" <|
                \_ ->
                    tcpConnectivitySuccess 80
                        (build |> withGroup allowAllInOut |> toNode)
                        internet
            , test "ec2 cannot reach internet with empty security group" <|
                \_ ->
                    tcpConnectivityFailure 80
                        (build |> withGroup allowNothing |> toNode)
                        internet
            ]
        , describe "internet --> Ec2"
            [ test "internet can reach ec2 with allowAll security group" <|
                \_ ->
                    tcpConnectivitySuccess 80
                        internet
                        (build |> withGroup allowAllInOut |> toNode)
            , test "internet cannot reach ec2 with empty security group" <|
                \_ ->
                    tcpConnectivityFailure 80
                        internet
                        (build |> withGroup allowNothing |> toNode)
            ]
        ]



-- Ec2 Fixture


build : Ec2.Config Node.Config
build =
    { id = "some-id"
    , securityGroups = []
    , privateIp = IpAddress.madeUpV4
    }


withGroup : SecurityGroup -> Ec2.Config Node.Config -> Ec2.Config Node.Config
withGroup group builder =
    { builder | securityGroups = group :: builder.securityGroups }


toNode : Ec2.Config Node.Config -> Node
toNode builder =
    Node.buildEc2 builder



-- end of Ec2 Fixture


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


tcpConnectivitySuccess : Port -> Node -> Node -> Expect.Expectation
tcpConnectivitySuccess overPort from =
    checkTcpConnectivity overPort from >> isPossible


tcpConnectivityFailure : Port -> Node -> Node -> Expect.Expectation
tcpConnectivityFailure overPort from =
    checkTcpConnectivity overPort from >> isNotPossible
