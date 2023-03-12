module SpaceIdSpec exposing (..)

import Expect
import Fuzz exposing (string)
import Json.Decode as Decode
import Json.Encode as Encode
import SpaceId exposing (decoder)
import Test exposing (..)


suite : Test
suite =
    describe "[SpaceId]"
        [ fuzz string "decoder maps a string to a SpaceId" <|
            \id ->
                Encode.string id
                    |> Decode.decodeValue decoder
                    |> Expect.ok
        ]
