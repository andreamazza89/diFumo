import {Elm} from './elm/Main.elm'
import {
    EC2Client,
    DescribeVpcsCommand,
    DescribeSubnetsCommand,
    DescribeSecurityGroupsCommand,
    DescribeInstancesCommand,
    DescribeRouteTablesCommand
} from "@aws-sdk/client-ec2";


const {ports} = Elm.Main.init({
    node: document.querySelector('main')
})

ports.fetchAwsData.subscribe(creds => {
        const client = new EC2Client({
            region: "eu-west-1",
            credentials: creds
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
                    vpcsResponse : vpcs.Vpcs,
                    subnetsResponse : subnets.Subnets,
                    securityGroupsResponse : securityGroups.SecurityGroups,
                    instancesResponse : instances.Reservations,
                    routeTablesResponse : routeTables.RouteTables
                }
                console.log(awsData)
                ports.awsDataReceived.send(awsData)
            })
    }
)
