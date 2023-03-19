module EventIdSpec exposing (..)

import EventId
import Expect
import Fuzz exposing (string)
import Json.Decode as D
import Json.Encode as E
import Test exposing (..)


suite : Test
suite =
    describe "[EventId]"
        [ fuzz string "decoder maps a string to a EventId" <|
            \id ->
                E.string id
                    |> D.decodeValue EventId.decoder
                    |> Expect.ok
        ]
