module Utils exposing (mkTestAttribute, posixToString)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Time


mkTestAttribute : String -> Attribute msg
mkTestAttribute =
    Attr.attribute "data-testid" << String.toLower


posixToStringShort : Time.Posix -> String
posixToStringShort posix =
    ""


posixToString : Time.Posix -> Time.Zone -> String
posixToString posix tz =
    let
        year : String
        year =
            Time.toYear tz posix
                |> String.fromInt

        month : String
        month =
            case Time.toMonth tz posix of
                Time.Jan ->
                    "Jan"

                Time.Feb ->
                    "Feb"

                Time.Mar ->
                    "Mar"

                Time.Apr ->
                    "Apr"

                Time.May ->
                    "May"

                Time.Jun ->
                    "Jun"

                Time.Jul ->
                    "Jul"

                Time.Aug ->
                    "Aug"

                Time.Sep ->
                    "Sep"

                Time.Oct ->
                    "Oct"

                Time.Nov ->
                    "Nov"

                Time.Dec ->
                    "Dec"

        day : String
        day =
            Time.toDay tz posix
                |> (\d ->
                        case d of
                            1 ->
                                "1st"

                            2 ->
                                "2nd"

                            3 ->
                                "3rd"

                            _ ->
                                String.fromInt d ++ "th"
                   )

        hour : String
        hour =
            Time.toHour tz posix
                |> (\h ->
                        if h < 10 then
                            "0" ++ String.fromInt h

                        else
                            String.fromInt h
                   )

        minutes : String
        minutes =
            Time.toMinute tz posix
                |> (\m ->
                        if m < 10 then
                            "0" ++ String.fromInt m

                        else
                            String.fromInt m
                   )

        seconds : String
        seconds =
            Time.toSecond tz posix
                |> (\s ->
                        if s < 10 then
                            "0" ++ String.fromInt s

                        else
                            String.fromInt s
                   )

        millis : String
        millis =
            Time.toMillis tz posix
                |> String.fromInt
    in
    day
        ++ " "
        ++ month
        ++ " "
        ++ year
        ++ " "
        ++ hour
        ++ ":"
        ++ minutes
        ++ ":"
        ++ seconds
        ++ "."
        ++ millis
