module Api exposing (..)

import Dict exposing (Dict)
import Node exposing (Node)
import Vpc.Subnet as Subnet exposing (Subnet)


type alias VpcsResponse =
    List {}


type alias InstancesResponse =
    List InstanceResponse


type alias InstanceResponse =
    { subnetId : String }


type alias SecurityGroupsResponse =
    List {}


type alias SubnetsResponse =
    List SubnetResponse


type alias SubnetResponse =
    { id : String
    , vpcId : String
    }


type alias SubnetId =
    String


type alias VpcId =
    String


buildVpc { vpcs, subnets, securityGroups, instances } =
    let
        nodesBySubnet =
            buildNodes instances securityGroups

        subnetsByVpc =
            buildSubnets nodesBySubnet subnets
    in
    42


buildNodes : InstancesResponse -> SecurityGroupsResponse -> Dict SubnetId (List Node)
buildNodes instances securityGroups =
    List.foldl (collectNode securityGroups) Dict.empty instances


collectNode : a -> InstanceResponse -> Dict SubnetId (List Node) -> Dict SubnetId (List Node)
collectNode securityGroups instance nodesBySubnet =
    let
        instance_ =
            Node.buildEc2Temp instance

        blah nodes =
            nodes
                |> Maybe.map ((::) instance_ >> Just)
                |> Maybe.withDefault (Just [ instance_ ])
    in
    Dict.update instance.subnetId blah nodesBySubnet


buildSubnets : Dict SubnetId (List Node) -> SubnetsResponse -> Dict VpcId (List Subnet)
buildSubnets nodesBySubnet subnets =
    List.foldl (collectSubnet nodesBySubnet) Dict.empty subnets


collectSubnet : Dict String (List Node) -> SubnetResponse -> Dict comparable (List Subnet) -> Dict comparable (List Subnet)
collectSubnet nodesBySubnet subnetResponse subnetsByVpc =
    let
        nodes =
            Dict.get subnetResponse.id nodesBySubnet
                |> Maybe.withDefault []

        blah subs =
            subs
                |> Maybe.map ((::) (Subnet.build subnetResponse.id nodes) >> Just)
                |> Maybe.withDefault (Just [ Subnet.build subnetResponse.id nodes ])
    in
    Dict.update subnetResponse.vpcId blah subnetsByVpc



-- TODO: write a Dict.upsert utility
