module AgentIdSpec exposing (..)

import AgentId
import Expect
import Fuzz exposing (string)
import Json.Decode as D
import Json.Encode as E
import Test exposing (..)


suite : Test
suite =
    describe "[AgentId]"
        [ fuzz string "decoder maps a string to an AgentId" <|
            \id ->
                E.string id
                    |> D.decodeValue AgentId.decoder
                    |> Expect.ok
        ]
