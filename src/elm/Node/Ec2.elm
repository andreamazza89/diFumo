module Node.Ec2 exposing
    ( Config
    , Ec2
    , allowsEgress
    , allowsIngress
    , build
    , build2
    , equals
    , hasInternetRoute
    , idAsString
    , ipAddress
    , securityGroups
    )

import IpAddress exposing (Ipv4Address)
import Vpc.RouteTable exposing (RouteTable)
import Vpc.SecurityGroup as SecurityGroup exposing (SecurityGroup)


type Ec2
    = Ec2
        { securityGroups : List SecurityGroup -- make nonempty -- maybe this should be lifted to the Node level, as any node other than the Internet has one or more security groups
        , id : Ec2Id
        , privateIp : Ipv4Address
        }


type Ec2Id
    = Ec2Id String


equals : Ec2 -> Ec2 -> Bool
equals ec2 otherEc2 =
    id ec2 == id otherEc2


ipAddress : Ec2 -> Ipv4Address
ipAddress (Ec2 ec2_) =
    ec2_.privateIp


securityGroups : Ec2 -> List SecurityGroup
securityGroups (Ec2 ec2_) =
    ec2_.securityGroups


id : Ec2 -> Ec2Id
id (Ec2 ec2_) =
    ec2_.id


idAsString : Ec2 -> String
idAsString ec2 =
    case id ec2 of
        Ec2Id id_ ->
            id_


hasInternetRoute : Ec2 -> Bool
hasInternetRoute (Ec2 _) =
    True


allowsEgress : SecurityGroup.Target -> Ec2 -> Bool
allowsEgress target ec2 =
    List.any (SecurityGroup.allowsEgress target) (securityGroups ec2)


allowsIngress : SecurityGroup.Target -> Ec2 -> Bool
allowsIngress target ec2 =
    List.any (SecurityGroup.allowsIngress target) (securityGroups ec2)



-- Builders


build : String -> List SecurityGroup -> RouteTable -> Ipv4Address -> Ec2
build id_ groups routeTable privateIp =
    Ec2
        { id = Ec2Id id_
        , securityGroups = groups
        , privateIp = privateIp
        }


type alias Config =
    { id : String
    , securityGroups : List SecurityGroup
    , privateIp : Ipv4Address
    }


build2 : Config -> Ec2
build2 config =
    Ec2
        { id = Ec2Id config.id
        , securityGroups = config.securityGroups
        , privateIp = config.privateIp
        }
