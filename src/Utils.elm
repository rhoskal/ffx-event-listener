module Utils exposing (mkTestAttribute, posixToString)

import DateFormat
import Html exposing (Attribute)
import Html.Attributes as Attr
import Time


mkTestAttribute : String -> Attribute msg
mkTestAttribute =
    Attr.attribute "data-testid" << String.toLower


{-| Format: 3rd Mar 2023 17:08:03.519
-}
posixToString : Time.Zone -> Time.Posix -> String
posixToString =
    DateFormat.format
        [ DateFormat.monthSuffix
        , DateFormat.text " "
        , DateFormat.monthNameAbbreviated
        , DateFormat.text " "
        , DateFormat.yearNumber
        , DateFormat.text " "
        , DateFormat.hourMilitaryFixed
        , DateFormat.text ":"
        , DateFormat.minuteFixed
        , DateFormat.text ":"
        , DateFormat.secondFixed
        , DateFormat.text "."
        , DateFormat.millisecondFixed
        ]
