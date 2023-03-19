module SpaceIdSpec exposing (..)

import Expect
import Fuzz exposing (string)
import Json.Decode as D
import Json.Encode as E
import SpaceId
import Test exposing (..)


suite : Test
suite =
    describe "[SpaceId]"
        [ fuzz string "decoder maps a string to a SpaceId" <|
            \id ->
                E.string id
                    |> D.decodeValue SpaceId.decoder
                    |> Expect.ok
        ]
