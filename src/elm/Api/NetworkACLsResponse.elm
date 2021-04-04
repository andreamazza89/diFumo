module Api.NetworkACLsResponse exposing (NetworkACLsResponse, decoder, find)

import Cidr exposing (Cidr)
import Json.Decode as Json
import Port exposing (Port)
import Protocol exposing (Protocol)
import Vpc.NetworkACL as NetworkACL exposing (NetworkACL)



-- Network Access Control List Response


type alias NetworkACLsResponse =
    List NetworkACLResponse


type alias NetworkACLResponse =
    { subnetsAssociated : List SubnetId
    , acl : NetworkACL
    }


type alias RuleResponse =
    { cidr : Cidr
    , isEgress : Bool
    , protocol : Protocol
    , fromPort : Port
    , toPort : Port
    , action : NetworkACL.Action
    , ruleNumber : Int
    }


type alias SubnetId =
    String



-- Query


find : SubnetId -> List NetworkACLResponse -> NetworkACL
find subnetId =
    List.filter (includesSubnet subnetId)
        >> List.head
        >> Maybe.map .acl
        -- TODO: rather than default to something wrong, change  buildVpcs to support failure with a Result type
        >> Maybe.withDefault (NetworkACL.build { ingressRules = [], egressRules = [] })


includesSubnet : SubnetId -> NetworkACLResponse -> Bool
includesSubnet subnetId =
    .subnetsAssociated >> List.member subnetId



-- Decoder


decoder : Json.Decoder NetworkACLsResponse
decoder =
    Json.list aclResponseDecoder


aclResponseDecoder : Json.Decoder NetworkACLResponse
aclResponseDecoder =
    Json.map2 NetworkACLResponse
        subnetAssociationsDecoder
        aclDecoder


subnetAssociationsDecoder : Json.Decoder (List String)
subnetAssociationsDecoder =
    Json.field "Associations" (Json.list subnetAssociationDecoder)


subnetAssociationDecoder : Json.Decoder String
subnetAssociationDecoder =
    Json.field "SubnetId" Json.string


aclDecoder : Json.Decoder NetworkACL
aclDecoder =
    Json.field "Entries"
        (Json.map NetworkACL.build
            (Json.map2 NetworkACL.Rules
                ingressRulesDecoder
                egressRulesDecoder
            )
        )


ingressRulesDecoder : Json.Decoder (List NetworkACL.Rule)
ingressRulesDecoder =
    Json.list ruleDecoder
        |> Json.map (List.filterMap toIngressRule)


toIngressRule : RuleResponse -> Maybe NetworkACL.Rule
toIngressRule ruleResponse =
    if ruleResponse.isEgress then
        Nothing

    else
        Just (NetworkACL.buildRule ruleResponse)


egressRulesDecoder : Json.Decoder (List NetworkACL.Rule)
egressRulesDecoder =
    Json.list ruleDecoder
        |> Json.map (List.filterMap toEgressRule)


toEgressRule : RuleResponse -> Maybe NetworkACL.Rule
toEgressRule ruleResponse =
    if ruleResponse.isEgress then
        Just (NetworkACL.buildRule ruleResponse)

    else
        Nothing


ruleDecoder : Json.Decoder RuleResponse
ruleDecoder =
    Json.map7 RuleResponse
        (Json.field "CidrBlock" Cidr.decoder)
        (Json.field "Egress" Json.bool)
        (Json.field "Protocol" Protocol.decoder)
        fromPortDecoder
        toPortDecoder
        (Json.field "RuleAction" NetworkACL.actionDecoder)
        ruleNumberDecoder


fromPortDecoder : Json.Decoder Port
fromPortDecoder =
    Json.oneOf
        [ Json.field "PortRange" (Json.field "From" Port.decoder)
        , Json.succeed Port.first
        ]


toPortDecoder : Json.Decoder Port
toPortDecoder =
    Json.oneOf
        [ Json.field "PortRange" (Json.field "To" Port.decoder)
        , Json.succeed Port.last
        ]


ruleNumberDecoder : Json.Decoder Int
ruleNumberDecoder =
    Json.field "RuleNumber" Json.int
