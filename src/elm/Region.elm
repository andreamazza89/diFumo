module Region exposing (Region(..), id, options)


type Region
    = UsEast1
    | UsEast2
    | UsWest1
    | UsWest2
    | AfSouth1
    | ApEast1
    | ApSouth1
    | ApNortheast3
    | ApNortheast2
    | ApSoutheast1
    | ApSoutheast2
    | ApNortheast1
    | CaCentral1
    | EuCentral1
    | EuWest1
    | EuWest2
    | EuSouth1
    | EuWest3
    | EuNorth1
    | MeSouth1
    | SaEast1


id : Region -> String
id region =
    case region of
        UsEast1 ->
            "us-east-1"

        UsEast2 ->
            "us-east-2"

        UsWest1 ->
            "us-west-1"

        UsWest2 ->
            "us-west-2"

        AfSouth1 ->
            "af-south-1"

        ApEast1 ->
            "ap-east-1"

        ApSouth1 ->
            "ap-south-1"

        ApNortheast3 ->
            "ap-northeast-3"

        ApNortheast2 ->
            "ap-northeast-2"

        ApSoutheast1 ->
            "ap-southeast-1"

        ApSoutheast2 ->
            "ap-southeast-2"

        ApNortheast1 ->
            "ap-northeast-1"

        CaCentral1 ->
            "ca-central-1"

        EuCentral1 ->
            "eu-central-1"

        EuWest1 ->
            "eu-west-1"

        EuWest2 ->
            "eu-west-2"

        EuSouth1 ->
            "eu-south-1"

        EuWest3 ->
            "eu-west-3"

        EuNorth1 ->
            "eu-north-1"

        MeSouth1 ->
            "me-south-1"

        SaEast1 ->
            "sa-east-1"


all : List Region
all =
    [ UsEast1
    , UsEast2
    , UsWest1
    , UsWest2
    , AfSouth1
    , ApEast1
    , ApSouth1
    , ApNortheast3
    , ApNortheast2
    , ApSoutheast1
    , ApSoutheast2
    , ApNortheast1
    , CaCentral1
    , EuCentral1
    , EuWest1
    , EuWest2
    , EuSouth1
    , EuWest3
    , EuNorth1
    , MeSouth1
    , SaEast1
    ]


options : List ( Region, String )
options =
    List.map (\region -> ( region, id region )) all
