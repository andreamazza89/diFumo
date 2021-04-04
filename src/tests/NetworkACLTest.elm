module NetworkACLTest exposing (suite)

import Cidr exposing (Cidr)
import Expect exposing (Expectation)
import Fixtures.Cidr exposing (cidr)
import Fixtures.IpAddress as IpAddress exposing (fromList)
import IpAddress exposing (Ipv4Address)
import Port
import Protocol
import Test exposing (Test, describe, fuzz, test)
import Vpc.NetworkACL as NetworkACL exposing (Action(..), Rule)


suite : Test
suite =
    describe "Network ACL"
        [ fuzz IpAddress.fuzzAny "By default, it blocks all inbound traffic" <|
            \address ->
                inboundTrafficIsNotAllowed address
                    { ingressRules = []
                    , egressRules = []
                    }
        , fuzz IpAddress.fuzzAny "By default, it blocks all outbound traffic" <|
            \address ->
                outboundTrafficIsNotAllowed address
                    { ingressRules = []
                    , egressRules = []
                    }
        , fuzz IpAddress.fuzzAny "Allows all inbound traffic given a permissive rule" <|
            \address ->
                inboundTrafficIsAllowed address
                    { ingressRules = [ allowAll 1 ]
                    , egressRules = []
                    }
        , fuzz IpAddress.fuzzAny "Allows all outbound traffic given a permissive rule" <|
            \address ->
                outboundTrafficIsAllowed address
                    { ingressRules = []
                    , egressRules = [ allowAll 1 ]
                    }
        , fuzz IpAddress.fuzzAny "Rules number is taken into consideration" <|
            \address ->
                inboundTrafficIsNotAllowed address
                    { ingressRules = [ disallowAll 1, allowAll 2 ]
                    , egressRules = []
                    }
        , test "The first matching rule is taken into account (example 1)" <|
            \_ ->
                inboundTrafficIsAllowed addressOne
                    { ingressRules = [ disallowAddressTwo 1, allowAddressOne 2 ]
                    , egressRules = []
                    }
        , test "The first matching rule is taken into account (example 2)" <|
            \_ ->
                outboundTrafficIsNotAllowed addressOne
                    { ingressRules = []
                    , egressRules = [ disallowAddressTwo 1, disallowAddressOne 2, allowAddressOne 3 ]
                    }
        ]


addressOne : Maybe Ipv4Address
addressOne =
    fromList [ 1, 1, 1, 1 ]


addressOneCidr : Cidr
addressOneCidr =
    cidr [ 1, 1, 1, 1 ] 32
        |> Maybe.withDefault Cidr.everywhere


addressTwoCidr : Cidr
addressTwoCidr =
    cidr [ 1, 2, 3, 4 ] 32
        |> Maybe.withDefault Cidr.everywhere


allowAll : Int -> Rule
allowAll ruleNumber =
    { cidr = Cidr.everywhere
    , protocol = Protocol.all
    , fromPort = Port.first
    , toPort = Port.last
    , action = Allow
    , ruleNumber = ruleNumber
    }


disallowAll : Int -> Rule
disallowAll =
    allowAll >> (\rule -> { rule | action = Deny })


disallowAddressOne : Int -> Rule
disallowAddressOne =
    disallowAll >> (\rule -> { rule | cidr = addressOneCidr })


disallowAddressTwo : Int -> Rule
disallowAddressTwo =
    disallowAll >> (\rule -> { rule | cidr = addressTwoCidr })


allowAddressOne : Int -> Rule
allowAddressOne =
    allowAll >> (\rule -> { rule | cidr = addressOneCidr })


inboundTrafficIsAllowed : Maybe Ipv4Address -> NetworkACL.Rules -> Expectation
inboundTrafficIsAllowed address rules =
    address
        |> Maybe.map (checkInbound rules True)
        |> Maybe.withDefault (Expect.fail "missing ip address")


inboundTrafficIsNotAllowed : Maybe Ipv4Address -> NetworkACL.Rules -> Expectation
inboundTrafficIsNotAllowed address rules =
    address
        |> Maybe.map (checkInbound rules False)
        |> Maybe.withDefault (Expect.fail "missing ip address")


outboundTrafficIsAllowed : Maybe Ipv4Address -> NetworkACL.Rules -> Expectation
outboundTrafficIsAllowed address rules =
    address
        |> Maybe.map (checkOutbound rules True)
        |> Maybe.withDefault (Expect.fail "missing ip address")


outboundTrafficIsNotAllowed : Maybe Ipv4Address -> NetworkACL.Rules -> Expectation
outboundTrafficIsNotAllowed address rules =
    address
        |> Maybe.map (checkOutbound rules False)
        |> Maybe.withDefault (Expect.fail "missing ip address")


checkInbound : NetworkACL.Rules -> Bool -> Ipv4Address -> Expectation
checkInbound rules expect address_ =
    NetworkACL.build rules
        |> NetworkACL.allowsIngress
            { ip = address_
            , forProtocol = Protocol.tcp
            , overPort = 80
            }
        |> toExpect expect


checkOutbound : NetworkACL.Rules -> Bool -> Ipv4Address -> Expectation
checkOutbound rules expect address_ =
    NetworkACL.build rules
        |> NetworkACL.allowsEgress
            { ip = address_
            , forProtocol = Protocol.tcp
            , overPort = 80
            }
        |> toExpect expect


toExpect : Bool -> Bool -> Expectation
toExpect expectTrue =
    if expectTrue then
        Expect.true "Expected ACL to allow traffic for this address"

    else
        Expect.false "Expected ACL to NOT allow traffic for this address"
