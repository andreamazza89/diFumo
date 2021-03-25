module Protocol exposing
    ( Protocol
    , all
    , matches
    , tcp
    )


type Protocol
    = Tcp
    | All


tcp : Protocol
tcp =
    Tcp


all : Protocol
all =
    All


matches : Protocol -> Protocol -> Bool
matches this that =
    case ( this, that ) of
        ( Tcp, Tcp ) ->
            True

        ( All, _ ) ->
            True

        ( _, All ) ->
            True
