module Protocol exposing
    ( Protocol
    , all
    , decoder
    , matches
    , tcp
    )

import Json.Decode as Json



-- Protocol


type Protocol
    = Tcp
    | All



-- Build


tcp : Protocol
tcp =
    Tcp


all : Protocol
all =
    All



-- Query


matches : Protocol -> Protocol -> Bool
matches this that =
    case ( this, that ) of
        ( Tcp, Tcp ) ->
            True

        ( All, _ ) ->
            True

        ( _, All ) ->
            True



-- Decode


decoder : Json.Decoder Protocol
decoder =
    Json.string
        |> Json.andThen
            (\protocol ->
                case protocol of
                    "tcp" ->
                        Json.succeed tcp

                    "6" ->
                        -- some services use the protocol code instead of its name, so tcp can either be "tcp" or "6"
                        Json.succeed tcp

                    "-1" ->
                        Json.succeed all

                    _ ->
                        Json.fail ("Unrecognised ip protocol: " ++ protocol)
            )
