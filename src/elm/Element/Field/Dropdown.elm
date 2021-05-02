module Element.Field.Dropdown exposing (view)

import Element exposing (..)
import Element.Scale as Scale
import Html exposing (Html)
import Html.Attributes exposing (style)
import Html.Events as Events
import Json.Decode as Json
import Utils.List as List


type alias Options msg option =
    { onChange : Maybe option -> msg
    , options : List ( option, String )
    , value : Maybe option
    }


view : Options msg option -> Element msg
view =
    view_ >> html >> el [ padding Scale.verySmall ]


view_ : Options msg option -> Html msg
view_ options =
    let
        changeHandler : Json.Decoder msg
        changeHandler =
            Json.map
                (String.toInt
                    >> Maybe.andThen (\i -> List.getAt i options.options)
                    >> Maybe.map Tuple.first
                    >> options.onChange
                )
                Events.targetValue

        onChange : Html.Attribute msg
        onChange =
            Events.on "change" changeHandler

        toOption : Int -> ( option, String ) -> Html msg
        toOption index ( key, label_ ) =
            Html.option
                [ Html.Attributes.value (String.fromInt index)
                , Html.Attributes.selected (options.value == Just key)
                ]
                [ Html.text label_ ]
    in
    Html.select
        [ onChange
        , style "border" "1px solid"
        , style "outline" "0"
        , style "border-radius" "5px"
        , style "padding" "5px"
        ]
        (List.indexedMap toOption options.options)
