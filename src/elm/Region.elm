module Region exposing (Region(..), id)


type Region
    = EuWest1


id : Region -> String
id region =
    case region of
        EuWest1 ->
            "eu-west-1"
