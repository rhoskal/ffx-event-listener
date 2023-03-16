module AgentIdSpec exposing (..)

import AgentId exposing (decoder)
import Expect
import Fuzz exposing (string)
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)


suite : Test
suite =
    describe "[AgentId]"
        [ fuzz string "decoder maps a string to an AgentId" <|
            \id ->
                Encode.string id
                    |> Decode.decodeValue decoder
                    |> Expect.ok
        ]
