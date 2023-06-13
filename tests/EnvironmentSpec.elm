module EnvironmentSpec exposing (..)

import Environment
import Expect
import Fuzz exposing (string)
import Json.Decode as D
import Json.Encode as E
import Test exposing (..)


suite : Test
suite =
    describe "[Environment]"
        [ fuzz3 string string string "environmentDecoder maps required fields to an Environment" <|
            \id accountId name ->
                [ ( "id", E.string id )
                , ( "accountId", E.string accountId )
                , ( "name", E.string name )
                , ( "isProd", E.bool False )
                ]
                    |> E.object
                    |> D.decodeValue Environment.decoder
                    |> Expect.ok
        , fuzz2 string string "environmentDecoder fails to map required fields to an Environemnt" <|
            \id name ->
                [ ( "id", E.string id )
                , ( "name", E.string name )
                ]
                    |> E.object
                    |> D.decodeValue Environment.decoder
                    |> Expect.err
        ]
