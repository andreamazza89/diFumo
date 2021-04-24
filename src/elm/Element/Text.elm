module Element.Text exposing (header, smallText, text)

import Element exposing (..)
import Element.Font as Font


header : List (Attribute msg) -> String -> Element msg
header attributes content =
    el ([ Font.bold ] ++ attributes) (Element.text content)


text : List (Attribute msg) -> String -> Element msg
text attributes content =
    el attributes (Element.text content)


smallText : List (Attribute msg) -> String -> Element msg
smallText attributes content =
    el ([ Font.size 14 ] ++ attributes) (Element.text content)
