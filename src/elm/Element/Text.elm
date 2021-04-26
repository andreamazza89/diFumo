module Element.Text exposing (fieldLabel, header, nodeLabel, smallText, text)

import Element exposing (..)
import Element.Colors as Colors
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


fieldLabel : List (Attr () msg) -> String -> Element msg
fieldLabel attributes content =
    el ([ Font.size 16, Font.color Colors.darkGrey ] ++ attributes) (Element.text (String.toUpper content))


nodeLabel : List (Attribute msg) -> String -> Element msg
nodeLabel attributes =
    smallText ([ Font.bold ] ++ attributes)
