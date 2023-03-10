module Utils exposing (mkTestAttribute, posixToString)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Time exposing (Month(..), Posix)


mkTestAttribute : String -> Attribute msg
mkTestAttribute =
    Attr.attribute "data-testid" << String.toLower


posixToString : Posix -> String
posixToString time =
    let
        year : String
        year =
            String.fromInt (Time.toYear Time.utc time)

        month : String
        month =
            case Time.toMonth Time.utc time of
                Jan ->
                    "Jan"

                Feb ->
                    "Feb"

                Mar ->
                    "Mar"

                Apr ->
                    "Apr"

                May ->
                    "May"

                Jun ->
                    "Jun"

                Jul ->
                    "Jul"

                Aug ->
                    "Aug"

                Sep ->
                    "Sep"

                Oct ->
                    "Oct"

                Nov ->
                    "Nov"

                Dec ->
                    "Dec"

        day : String
        day =
            (\d ->
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
            <|
                Time.toDay Time.utc time

        hour : String
        hour =
            (\h ->
                if h > 12 then
                    "0" ++ String.fromInt (h - 12)

                else
                    "0" ++ String.fromInt h
            )
            <|
                Time.toHour Time.utc time

        minutes : String
        minutes =
            (\m ->
                if m < 10 then
                    "0" ++ String.fromInt m

                else
                    String.fromInt m
            )
            <|
                Time.toMinute Time.utc time

        seconds : String
        seconds =
            (\s ->
                if s < 10 then
                    "0" ++ String.fromInt s

                else
                    String.fromInt s
            )
            <|
                Time.toSecond Time.utc time

        millis : String
        millis =
            String.fromInt (Time.toMillis Time.utc time)
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
