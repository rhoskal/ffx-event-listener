module EnvironmentIdSpec exposing (..)

import EnvironmentId exposing (decoder)
import Expect
import Fuzz exposing (string)
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)


suite : Test
suite =
    describe "[EnvironmentId]"
        [ fuzz string "decoder maps a string to a EnvironmentId" <|
            \id ->
                Encode.string id
                    |> Decode.decodeValue decoder
                    |> Expect.ok
        ]
