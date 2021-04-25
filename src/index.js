import {Elm} from './elm/Main.elm'
import {
    EC2Client,
    DescribeVpcsCommand,
    DescribeSubnetsCommand,
    DescribeSecurityGroupsCommand,
    DescribeInstancesCommand,
    DescribeRouteTablesCommand,
    DescribeNetworkAclsCommand,
    DescribeNetworkInterfacesCommand,
} from "@aws-sdk/client-ec2";
import {RDSClient, DescribeDBInstancesCommand} from "@aws-sdk/client-rds"
import {ECSClient, ListClustersCommand, ListTasksCommand, DescribeTasksCommand} from "@aws-sdk/client-ecs"
import {ElasticLoadBalancingV2, DescribeLoadBalancersCommand} from "@aws-sdk/client-elastic-load-balancing-v2"

// stubbed responses below
import vpcsResponse from "./aws-fixtures/describe-vpcs.json"
import subnetsResponse from "./aws-fixtures/describe-subnets.json"
import securityGroupsResponse from "./aws-fixtures/describe-security-groups.json"
import instancesResponse from "./aws-fixtures/describe-instances.json"
import routeTablesResponse from "./aws-fixtures/describe-route-tables.json"
import networkACLsResponse from "./aws-fixtures/describe-network-acls.json"
import networkInterfacesResponse from "./aws-fixtures/describe-network-interfaces.json"
import dbInstancesResponse from "./aws-fixtures/describe-db-instances.json"
import ecsTasksResponse from "./aws-fixtures/describe-ecs-tasks.json"
import loadBalancersResponse from "./aws-fixtures/describe-load-balancers.json"


const environment = process.env.NODE_ENV

const {ports} = Elm.Main.init({
    node: document.querySelector('main')
})

ports.fetchAwsData.subscribe(creds => {
        buildAwsClient(environment, creds, ports.awsDataReceived.send)
            .fetchIt()
    }
)

const buildAwsClient = (environment, credentials, onDataReceived) => {
    switch (environment) {
        case "development":
            return awsClient(credentials, onDataReceived);
        case "stubbed":
            return stubbedClient(onDataReceived);
    }
}

const awsClient = (credentials, onDataReceived) => (
    {
        fetchIt: () => {
            const ec2Client = new EC2Client({
                region: "eu-west-1",
                credentials: credentials
            });

            const rdsClient = new RDSClient({
                region: "eu-west-1",
                credentials: credentials
            });

            const elbClient = new ElasticLoadBalancingV2({
                region: "eu-west-1",
                credentials: credentials
            });

            Promise
                .all([
                    ec2Client.send(new DescribeVpcsCommand({})),
                    ec2Client.send(new DescribeSubnetsCommand({})),
                    ec2Client.send(new DescribeSecurityGroupsCommand({})),
                    ec2Client.send(new DescribeInstancesCommand({})),
                    ec2Client.send(new DescribeRouteTablesCommand({})),
                    ec2Client.send(new DescribeNetworkAclsCommand({})),
                    ec2Client.send(new DescribeNetworkInterfacesCommand({})),
                    rdsClient.send(new DescribeDBInstancesCommand({})),
                    getTheEcs(credentials),
                    elbClient.send(new DescribeLoadBalancersCommand({})),
                ])
                .then(responses => {
                    const [
                        vpcs,
                        subnets,
                        securityGroups,
                        instances,
                        routeTables,
                        networkACLs,
                        networkInterfaces,
                        dbInstances,
                        ecsTasks,
                        loadBalancers,
                    ] = responses

                    const awsData = {
                        vpcsResponse: vpcs.Vpcs,
                        subnetsResponse: subnets.Subnets,
                        securityGroupsResponse: securityGroups.SecurityGroups,
                        instancesResponse: instances.Reservations,
                        routeTablesResponse: routeTables.RouteTables,
                        networkACLsResponse: networkACLs.NetworkAcls,
                        networkInterfacesResponse: networkInterfaces.NetworkInterfaces,
                        dbInstancesResponse: dbInstances.DBInstances,
                        ecsTasksResponse: ecsTasks.Tasks,
                        loadBalancersResponse: loadBalancers.LoadBalancers,
                    }
                    console.log(awsData)
                    onDataReceived(awsData)
                })
        }
    }
)

const stubbedClient = (onDataReceived) => (
    {
        fetchIt: () => {
            const awsData = {
                vpcsResponse: vpcsResponse.Vpcs,
                subnetsResponse: subnetsResponse.Subnets,
                securityGroupsResponse: securityGroupsResponse.SecurityGroups,
                instancesResponse: instancesResponse.Reservations,
                routeTablesResponse: routeTablesResponse.RouteTables,
                networkACLsResponse: networkACLsResponse.NetworkAcls,
                networkInterfacesResponse: networkInterfacesResponse.NetworkInterfaces,
                dbInstancesResponse: dbInstancesResponse.DBInstances,
                ecsTasksResponse: ecsTasksResponse.Tasks,
                loadBalancersResponse: loadBalancersResponse.LoadBalancers,
            }
            onDataReceived(awsData)
        }
    }
)


// messing with ECS

function getTheEcs(credentials) {
    const client = new ECSClient({
        region: "eu-west-1",
        credentials: credentials
    });

    return client
        .send(new ListClustersCommand({}))
        .then(clusters => Promise.all(
            clusters.clusterArns.map(cluster =>
                client
                    .send(new ListTasksCommand({cluster: cluster}))
                    .then(tasks => ({
                            taskArns: tasks.taskArns,
                            cluster: cluster
                        })
                    )
            )))
        .then(tasks => Promise.all(
            tasks.map(taskStuff => client.send(new DescribeTasksCommand({
                tasks: taskStuff.taskArns,
                cluster: taskStuff.cluster
            })))
        ))
        .then(describedTasks =>
            ({Tasks: describedTasks.flatMap(tasks => tasks.tasks)})
        )

}
