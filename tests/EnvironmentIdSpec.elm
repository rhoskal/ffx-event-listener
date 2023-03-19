module EnvironmentIdSpec exposing (..)

import EnvironmentId
import Expect
import Fuzz exposing (string)
import Json.Decode as D
import Json.Encode as E
import Test exposing (..)


suite : Test
suite =
    describe "[EnvironmentId]"
        [ fuzz string "decoder maps a string to a EnvironmentId" <|
            \id ->
                E.string id
                    |> D.decodeValue EnvironmentId.decoder
                    |> Expect.ok
        ]
