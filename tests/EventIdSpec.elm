module EventIdSpec exposing (..)

import EventId exposing (decoder)
import Expect
import Fuzz exposing (string)
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)


suite : Test
suite =
    describe "[EventId]"
        [ fuzz string "decoder maps a string to a EventId" <|
            \id ->
                Encode.string id
                    |> Decode.decodeValue decoder
                    |> Expect.ok
        ]
