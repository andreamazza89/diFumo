module Utils.Maybe exposing (oneOf)


oneOf : Maybe a -> Maybe a -> Maybe a
oneOf this theOther =
    case this of
        Just _ ->
            this

        Nothing ->
            theOther
