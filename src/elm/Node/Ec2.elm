module Node.Ec2 exposing
    ( Ec2
    , allowsEgress
    , build
    , hasInternetRoute
    , idAsString
    , ipAddress
    , securityGroups
    )

import IpAddress exposing (IpAddress)
import Vpc.RouteTable exposing (RouteTable)
import Vpc.SecurityGroup as SecurityGroup exposing (SecurityGroup)



-- Mention something here about the denormalisation. This will make it much easier to access the necessary information
-- when looking at an instance without the need to look it up from its parents.
-- The catches are:
--   1. All is (relatively) well as long as this data structure (and the whole Vpc tree) is read-only.
--   2. For testing, we should take extra care to prevent building invalid states


type Ec2
    = Ec2
        { securityGroups : List SecurityGroup
        , id : Ec2Id
        , routeTable : RouteTable
        , privateIp : IpAddress
        }


type Ec2Id
    = Ec2Id String


ipAddress : Ec2 -> IpAddress
ipAddress (Ec2 ec2_) =
    ec2_.privateIp


securityGroups : Ec2 -> List SecurityGroup
securityGroups (Ec2 ec2_) =
    ec2_.securityGroups


idAsString : Ec2 -> String
idAsString (Ec2 { id }) =
    case id of
        Ec2Id id_ ->
            id_


hasInternetRoute : Ec2 -> Bool
hasInternetRoute (Ec2 ec2_) =
    True


allowsEgress : SecurityGroup.Target -> Ec2 -> Bool
allowsEgress target ec2 =
    List.any (SecurityGroup.allowsEgress target) (securityGroups ec2)



-- Builders


build : String -> List SecurityGroup -> RouteTable -> IpAddress -> Ec2
build id groups routeTable privateIp =
    Ec2
        { id = Ec2Id id
        , securityGroups = groups
        , routeTable = routeTable
        , privateIp = privateIp
        }
