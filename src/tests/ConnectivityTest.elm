module ConnectivityTest exposing (suite)

import Cidr
import Connectivity exposing (Connectivity, ConnectivityContext)
import Expect
import IpAddress exposing (Ipv4Address)
import Node exposing (Node)
import Node.Ec2 as Ec2
import Port exposing (Port)
import Protocol
import Test exposing (Test, describe, test)
import Vpc.SecurityGroup as SecurityGroup exposing (SecurityGroup)


suite : Test
suite =
    describe "Connectivity"
        [ describe "Ec2s and the internet"
            [ test "internet traffic allowed with allowAll security group" <|
                \_ ->
                    tcpConnectivitySuccess 80
                        (build |> withGroup allowAllInOut |> toNode)
                        internet
            , test "internet traffic not allowed with empty security group" <|
                \_ ->
                    tcpConnectivityFailure 80
                        (build |> withGroup allowNothing |> toNode)
                        internet
            ]
        ]



-- SecurityGroup Fixture


allowAllInOut : SecurityGroup
allowAllInOut =
    SecurityGroup.build "some-security-group-id" allowAll allowAll


allowNothing : SecurityGroup
allowNothing =
    SecurityGroup.build "some-security-group-id" [] []


allowAll : List SecurityGroup.Rule_
allowAll =
    [ { forProtocol = Protocol.all
      , fromPort = Port.first
      , toPort = Port.last
      , cidrs = [ Cidr.everywhere ]
      }
    ]



-- Ec2 Fixture


build : Ec2.Config
build =
    { id = "some-id"
    , securityGroups = []
    , privateIp = IpAddress.madeUpV4
    }


withGroup : SecurityGroup -> Ec2.Config -> Ec2.Config
withGroup group builder =
    { builder | securityGroups = group :: builder.securityGroups }


toNode builder =
    Node.buildEc2 builder



-- end of Ec2 Fixture


internet : Node
internet =
    Node.internet


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
