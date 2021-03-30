import {Elm} from './elm/Main.elm'
import {
    EC2Client,
    DescribeVpcsCommand,
    DescribeSubnetsCommand,
    DescribeSecurityGroupsCommand,
    DescribeInstancesCommand,
    DescribeRouteTablesCommand
} from "@aws-sdk/client-ec2";
import vpcsResponse from "./aws-fixtures/describe-vpcs.json"
import subnetsResponse from "./aws-fixtures/describe-subnets.json"
import securityGroupsResponse from "./aws-fixtures/describe-security-groups.json"
import instancesResponse from "./aws-fixtures/describe-instances.json"
import routeTablesResponse from "./aws-fixtures/describe-route-tables.json"


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
            const client = new EC2Client({
                region: "eu-west-1",
                credentials: credentials
            });

            Promise
                .all([
                    client.send(new DescribeVpcsCommand({})),
                    client.send(new DescribeSubnetsCommand({})),
                    client.send(new DescribeSecurityGroupsCommand({})),
                    client.send(new DescribeInstancesCommand({})),
                    client.send(new DescribeRouteTablesCommand({})),
                ])
                .then(responses => {
                    const [vpcs, subnets, securityGroups, instances, routeTables] = responses
                    const awsData = {
                        vpcsResponse: vpcs.Vpcs,
                        subnetsResponse: subnets.Subnets,
                        securityGroupsResponse: securityGroups.SecurityGroups,
                        instancesResponse: instances.Reservations,
                        routeTablesResponse: routeTables.RouteTables
                    }
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
                routeTablesResponse: routeTablesResponse.RouteTables
            }
            onDataReceived(awsData)
        }
    }
)
