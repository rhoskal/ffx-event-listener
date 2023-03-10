module Utils exposing (mkTestAttribute, posixToString)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Time exposing (Posix)


mkTestAttribute : String -> Attribute msg
mkTestAttribute =
    Attr.attribute "data-testid" << String.toLower


posixToString : Posix -> String
posixToString time =
    let
        year : String
        year =
            Time.toYear Time.utc time
                |> String.fromInt

        month : String
        month =
            case Time.toMonth Time.utc time of
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
            Time.toDay Time.utc time
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
            Time.toHour Time.utc time
                |> (\h ->
                        if h < 10 then
                            "0" ++ String.fromInt h

                        else
                            String.fromInt h
                   )

        minutes : String
        minutes =
            Time.toMinute Time.utc time
                |> (\m ->
                        if m < 10 then
                            "0" ++ String.fromInt m

                        else
                            String.fromInt m
                   )

        seconds : String
        seconds =
            Time.toSecond Time.utc time
                |> (\s ->
                        if s < 10 then
                            "0" ++ String.fromInt s

                        else
                            String.fromInt s
                   )

        millis : String
        millis =
            Time.toMillis Time.utc time
                |> String.fromInt
    in
    year
        ++ " "
        ++ month
        ++ " "
        ++ day
        ++ " "
        ++ hour
        ++ ":"
        ++ minutes
        ++ ":"
        ++ seconds
        ++ "."
        ++ millis
        ++ " (UTC)"
