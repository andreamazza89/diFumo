module Region exposing (Region(..), id, options)


type Region
    = EuWest1
    | EuWest2
    | UsEast1


id : Region -> String
id region =
    case region of
        EuWest1 ->
            "eu-west-1"

        EuWest2 ->
            "eu-west-2"

        UsEast1 ->
            "us-east-1"


all : List Region
all =
    [ EuWest1, EuWest2, UsEast1 ]


options : List ( Region, String )
options =
    List.map (\region -> ( region, id region )) all
