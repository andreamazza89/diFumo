module AwsFixtures.Elm exposing (instance, myVpc)

import Cidr
import IpAddress
import Node exposing (Node)
import Vpc exposing (Vpc)
import Vpc.RouteTable as RouteTable
import Vpc.SecurityGroup as SecurityGroup exposing (SecurityGroup)
import Vpc.Subnet as Subnet exposing (Subnet)



------ Fixtures


myVpc : Vpc
myVpc =
    Vpc.build "vpc-02a34f69639e5d566" [ subnetOne, subnetTwo ]


subnetOne : Subnet
subnetOne =
    Subnet.build "subnet-06b385372a02a26f9" [ instance "1" ]


subnetTwo : Subnet
subnetTwo =
    Subnet.build "subnet-08b385372a02a26f8" [ instance "2", instance "3" ]


instance : String -> Node
instance n =
    Node.buildEc2 ("i-09af59bfa9c2" ++ n ++ "a8ea")
        [ securityGroup ]
        RouteTable.build
        (IpAddress.buildV4 42 42 42 42)


securityGroup : SecurityGroup
securityGroup =
    SecurityGroup.build "Made up Security Group"
        [ { fromPort = 44, toPort = 55, cidr = Cidr.range 22 22 22 22 16 } ]
