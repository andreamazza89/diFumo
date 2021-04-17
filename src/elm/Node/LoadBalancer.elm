module Node.LoadBalancer exposing (Config, LoadBalancer, build, canAccessInternet, equals, idAsString)

import IpAddress exposing (Ipv4Address)


type LoadBalancer
    = LoadBalancer
        { id : LoadBalancerId
        , publiclyAccessible : Bool
        }


type LoadBalancerId
    = LoadBalancerId String


idAsString : LoadBalancer -> String
idAsString lb =
    case id lb of
        LoadBalancerId id_ ->
            id_


id : LoadBalancer -> LoadBalancerId
id (LoadBalancer lb) =
    lb.id


equals : LoadBalancer -> LoadBalancer -> Bool
equals lb otherLb =
    id lb == id otherLb


canAccessInternet : LoadBalancer -> Bool
canAccessInternet (LoadBalancer { publiclyAccessible }) =
    publiclyAccessible


type alias Config a =
    { a
        | arn : String
        , privateIp : Ipv4Address
        , publiclyAccessible : Bool
    }


build : Config a -> LoadBalancer
build config =
    LoadBalancer
        { id = LoadBalancerId (config.arn ++ IpAddress.toDecimalString config.privateIp)
        , publiclyAccessible = config.publiclyAccessible
        }
