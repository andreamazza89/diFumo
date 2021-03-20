module Node exposing
    ( Node
    , allowsEgress
    , buildEc2
    , equals
    , hasInternetRoute
    , idAsString
    , internet
    , isInternet
    )

import IpAddress exposing (IpAddress)
import Node.Ec2 as Ec2 exposing (Ec2)
import Port exposing (Port)
import Protocol exposing (Protocol)
import Vpc.RouteTable exposing (RouteTable)
import Vpc.SecurityGroup exposing (SecurityGroup)



-- Node


type Node
    = Ec2 Ec2
    | Internet



-- Query


equals : Node -> Node -> Bool
equals node otherNode =
    case ( node, otherNode ) of
        ( Internet, Internet ) ->
            True

        ( Ec2 ec2, Ec2 otherEc2 ) ->
            Ec2.equals ec2 otherEc2

        _ ->
            False


ipAddress : Node -> IpAddress
ipAddress node =
    case node of
        Internet ->
            -- this is some random address; perhaps we should build Internet node eliciting an address form the user?
            IpAddress.build 104 198 14 52

        Ec2 ec2 ->
            Ec2.ipAddress ec2


isInternet : Node -> Bool
isInternet node =
    case node of
        Internet ->
            True

        _ ->
            False


idAsString : Node -> String
idAsString node_ =
    case node_ of
        Ec2 ec2 ->
            Ec2.idAsString ec2

        Internet ->
            "internet"


allowsEgress : Node -> Node -> Protocol -> Port -> Bool
allowsEgress node toNode forProtocol overPort =
    case node of
        Internet ->
            -- If the source node is the internet, then security groups do not apply
            True

        Ec2 ec2 ->
            Ec2.allowsEgress
                { toIp = ipAddress toNode
                , forProtocol = forProtocol
                , overPort = overPort
                }
                ec2


hasInternetRoute : Node -> Bool
hasInternetRoute toNode =
    case toNode of
        Internet ->
            True

        Ec2 ec2 ->
            Ec2.hasInternetRoute ec2



-- Builders


buildEc2 : String -> List SecurityGroup -> RouteTable -> IpAddress -> Node
buildEc2 id securityGroups routeTable ipAddress_ =
    Ec2 (Ec2.build id securityGroups routeTable ipAddress_)


internet : Node
internet =
    Internet
