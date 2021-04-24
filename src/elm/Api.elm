module Api exposing (decodeAwsData)

import Api.EcsTasksResponse as EcsTasksResponse exposing (EcsTaskResponse, EcsTasksResponse)
import Api.InstancesResponse as InstancesResponse exposing (InstanceResponse, InstancesResponse)
import Api.LoadBalancersResponse as LoadBalancersResponse exposing (LoadBalancerResponse, LoadBalancersResponse)
import Api.NetworkACLsResponse as NetworkACLsResponse exposing (NetworkACLsResponse)
import Api.NetworkInterfacesResponse as NetworkInterfacesResponse exposing (NetworkInterfacesResponse)
import Api.RdsResponse as RdsResponse exposing (RdsResponse, RdsesResponse)
import Api.RouteTablesResponse as RouteTablesResponse exposing (RouteTablesResponse)
import Dict exposing (Dict)
import Json.Decode as Json
import Node exposing (Node)
import Utils.Dict as Dict
import Utils.Json as Json
import Utils.NonEmptyList as NonEmptyList exposing (NonEmptyList)
import Vpc exposing (Vpc)
import Vpc.SecurityGroup as SecurityGroup exposing (SecurityGroup)
import Vpc.Subnet as Subnet exposing (Subnet)


decodeAwsData : Json.Value -> Result String (NonEmptyList Vpc)
decodeAwsData =
    Json.decodeValue awsDataDecoder
        >> Result.mapError Json.errorToString
        >> Result.andThen buildVpcs
        >> Result.andThen NonEmptyList.fromList


awsDataDecoder : Json.Decoder AwsData
awsDataDecoder =
    Json.decode AwsData
        |> Json.key "vpcsResponse" vpcsDecoder
        |> Json.key "subnetsResponse" subnetsDecoder
        |> Json.key "securityGroupsResponse" securityGroupsDecoder
        |> Json.key "instancesResponse" InstancesResponse.decoder
        |> Json.key "routeTablesResponse" RouteTablesResponse.decoder
        |> Json.key "networkACLsResponse" NetworkACLsResponse.decoder
        |> Json.key "networkInterfacesResponse" NetworkInterfacesResponse.decoder
        |> Json.key "dbInstancesResponse" RdsResponse.decoder
        |> Json.key "ecsTasksResponse" EcsTasksResponse.decoder
        |> Json.key "loadBalancersResponse" LoadBalancersResponse.decoder


vpcsDecoder : Json.Decoder VpcsResponse
vpcsDecoder =
    Json.list vpcDecoder


vpcDecoder : Json.Decoder VpcResponse
vpcDecoder =
    Json.map VpcResponse (Json.field "VpcId" Json.string)


subnetsDecoder : Json.Decoder (List SubnetResponse)
subnetsDecoder =
    Json.list subnetDecoder


subnetDecoder : Json.Decoder SubnetResponse
subnetDecoder =
    Json.map2 SubnetResponse
        (Json.field "SubnetId" Json.string)
        (Json.field "VpcId" Json.string)


securityGroupsDecoder : Json.Decoder (List SecurityGroup)
securityGroupsDecoder =
    Json.list SecurityGroup.decoder


type alias AwsData =
    { vpcs : VpcsResponse
    , subnets : SubnetsResponse
    , securityGroups : List SecurityGroup
    , instances : InstancesResponse
    , routeTables : RouteTablesResponse
    , networkACLs : NetworkACLsResponse
    , networkInterfaces : NetworkInterfacesResponse
    , databases : RdsesResponse
    , ecsTasks : EcsTasksResponse
    , loadBalancers : LoadBalancersResponse
    }


type alias VpcsResponse =
    List VpcResponse


type alias VpcResponse =
    { id : VpcId }


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



-- Zipping up the api responses


buildVpcs : AwsData -> Result String (List Vpc)
buildVpcs ({ vpcs, subnets, securityGroups, instances, routeTables } as awsData) =
    buildNodes awsData
        |> Result.map (buildSubnets subnets)
        |> Result.map (buildVpcs_ vpcs)


buildVpcs_ : List VpcResponse -> Dict VpcId (List Subnet) -> List Vpc
buildVpcs_ vpcs subnetsByVpc =
    List.foldl (collectVpc subnetsByVpc) [] vpcs


collectVpc : Dict String (List Subnet) -> VpcResponse -> List Vpc -> List Vpc
collectVpc subnetsByVpc vpc vpcs =
    Vpc.build vpc.id (Dict.get vpc.id subnetsByVpc |> Maybe.withDefault []) :: vpcs


buildNodes : AwsData -> Result String (Dict SubnetId (List Node))
buildNodes awsData =
    collectInstances awsData
        |> collectDatabases awsData
        |> collectTasks awsData
        |> collectLoadBalancers awsData


collectInstances : AwsData -> Result String (Dict SubnetId (List Node))
collectInstances ({ instances } as awsData) =
    List.foldl (collectInstance awsData) (Result.Ok Dict.empty) instances


collectInstance : AwsData -> InstanceResponse -> Result String (Dict String (List Node)) -> Result String (Dict String (List Node))
collectInstance { securityGroups, routeTables, networkACLs } instance nodesBySubnet =
    let
        routeTable =
            RouteTablesResponse.find instance.vpcId instance.subnetId routeTables

        instance_ =
            Result.map
                (\rt ->
                    Node.buildEc2
                        { id = instance.id
                        , securityGroups = findSecurityGroups instance.securityGroups securityGroups
                        , privateIp = instance.privateIp
                        , routeTable = rt
                        , publicIp = instance.publicIp
                        , networkACL = NetworkACLsResponse.find instance.subnetId networkACLs
                        }
                )
                routeTable
    in
    Result.map2
        (Dict.updateList instance.subnetId)
        instance_
        nodesBySubnet


collectDatabases : AwsData -> Result String (Dict String (List Node)) -> Result String (Dict String (List Node))
collectDatabases awsData otherNodes =
    List.foldl (collectDatabase awsData) otherNodes awsData.databases


collectDatabase : AwsData -> RdsResponse -> Result String (Dict String (List Node)) -> Result String (Dict String (List Node))
collectDatabase { securityGroups, routeTables, networkACLs, networkInterfaces } database nodesBySubnet =
    let
        networkInfo =
            NetworkInterfacesResponse.findRdsInfo database networkInterfaces

        routeTable =
            Result.andThen
                (\info -> RouteTablesResponse.find database.vpcId info.subnetId routeTables)
                networkInfo

        instance_ =
            Result.map2
                (\rt ni ->
                    Node.buildRds
                        { id = database.id
                        , securityGroups = findSecurityGroups database.securityGroups securityGroups
                        , privateIp = ni.ip
                        , routeTable = rt
                        , isPubliclyAccessible = database.isPubliclyAccessible
                        , networkACL = NetworkACLsResponse.find ni.subnetId networkACLs
                        }
                )
                routeTable
                networkInfo
    in
    Result.map3
        (\ni -> Dict.updateList ni.subnetId)
        networkInfo
        instance_
        nodesBySubnet


collectTasks : AwsData -> Result String (Dict String (List Node)) -> Result String (Dict String (List Node))
collectTasks awsData otherNodes =
    List.foldl (collectTask awsData) otherNodes awsData.ecsTasks


collectTask : AwsData -> EcsTaskResponse -> Result String (Dict String (List Node)) -> Result String (Dict String (List Node))
collectTask { securityGroups, routeTables, networkACLs, networkInterfaces } task nodesBySubnet =
    let
        networkInfo =
            NetworkInterfacesResponse.findForAddress task.ip networkInterfaces

        routeTable =
            Result.andThen
                (\info -> RouteTablesResponse.find info.vpcId info.subnetId routeTables)
                networkInfo

        task_ =
            Result.map2
                (\ni rt ->
                    Node.buildEcsTask
                        { id = task.arn
                        , securityGroups = findSecurityGroups ni.securityGroups securityGroups
                        , privateIp = ni.ip
                        , routeTable = rt
                        , networkACL = NetworkACLsResponse.find ni.subnetId networkACLs
                        , group = task.group
                        }
                )
                networkInfo
                routeTable
    in
    Result.map3
        (\ni -> Dict.updateList ni.subnetId)
        networkInfo
        task_
        nodesBySubnet


collectLoadBalancers : AwsData -> Result String (Dict String (List Node)) -> Result String (Dict String (List Node))
collectLoadBalancers awsData otherNodes =
    List.foldl (collectLoadBalancer awsData) otherNodes awsData.loadBalancers


collectLoadBalancer : AwsData -> LoadBalancerResponse -> Result String (Dict String (List Node)) -> Result String (Dict String (List Node))
collectLoadBalancer { securityGroups, routeTables, networkACLs, networkInterfaces } loadBalancer nodesBySubnet =
    let
        networkInfo =
            NetworkInterfacesResponse.findLoadBalancerInfo loadBalancer networkInterfaces

        routeTable =
            Result.andThen
                (\info -> RouteTablesResponse.find info.vpcId info.subnetId routeTables)
                networkInfo

        task_ =
            Result.map2
                (\ni rt ->
                    Node.buildLoadBalancer
                        { arn = loadBalancer.arn
                        , securityGroups = findSecurityGroups ni.securityGroups securityGroups
                        , privateIp = ni.ip
                        , routeTable = rt
                        , networkACL = NetworkACLsResponse.find ni.subnetId networkACLs
                        , publiclyAccessible = loadBalancer.publiclyAccessible
                        }
                )
                networkInfo
                routeTable
    in
    Result.map3
        (\ni -> Dict.updateList ni.subnetId)
        networkInfo
        task_
        nodesBySubnet


buildSubnets : SubnetsResponse -> Dict SubnetId (List Node) -> Dict VpcId (List Subnet)
buildSubnets subnets nodesBySubnet =
    List.foldl (collectSubnet nodesBySubnet) Dict.empty subnets


collectSubnet : Dict String (List Node) -> SubnetResponse -> Dict VpcId (List Subnet) -> Dict VpcId (List Subnet)
collectSubnet nodesBySubnet subnetResponse subnetsByVpc =
    let
        nodes =
            Dict.get subnetResponse.id nodesBySubnet
                |> Maybe.withDefault []

        subnet =
            Subnet.build subnetResponse.id nodes
    in
    Dict.updateList subnetResponse.vpcId subnet subnetsByVpc


findSecurityGroups : List String -> List SecurityGroup -> List SecurityGroup
findSecurityGroups groupIds securityGroups =
    List.filter (\group -> List.member (SecurityGroup.idAsString group) groupIds) securityGroups



-- TODO: the instance decoder currently fails when you have a terminated instance, as it will not have a subnetId when terminated - we should just filter those out instead
-- TODO: when associating nodes to a vpc and route tables/networkACLs to nodes, we should key the Dict using <vpc-subnet> to avoid issues when the same subnetId is used across different VPCs. I think this is unlikely in the real world, but it's better to completely avoid it.
