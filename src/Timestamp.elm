module Timestamp exposing (decoder, toString)

import DateFormat
import Iso8601
import Json.Decode as D
import Time


{-| Format: 3rd Mar 2023 17:08:03.519
-}
toString : Time.Zone -> Time.Posix -> String
toString =
    DateFormat.format
        [ DateFormat.dayOfMonthSuffix
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



-- JSON


decoder : D.Decoder Time.Posix
decoder =
    Iso8601.decoder
