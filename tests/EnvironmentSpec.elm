module EnvironmentSpec exposing (..)

import Environment
    exposing
        ( environmentDecoder
        , environmentIdDecoder
        )
import Expect
import Fuzz exposing (string)
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)


suite : Test
suite =
    describe "Environment"
        [ fuzz3 string string string "environmentDecoder maps required fields to an Environment" <|
            \id accountId name ->
                [ ( "id", Encode.string id )
                , ( "accountId", Encode.string accountId )
                , ( "name", Encode.string name )
                ]
                    |> Encode.object
                    |> Decode.decodeValue environmentDecoder
                    |> Expect.ok
        , fuzz2 string string "environmentDecoder fails to map required fields to an Environemnt" <|
            \id name ->
                [ ( "id", Encode.string id )
                , ( "name", Encode.string name )
                ]
                    |> Encode.object
                    |> Decode.decodeValue environmentDecoder
                    |> Expect.err
        , fuzz string "environmentIdDecoder maps a string to an EnvironmentId" <|
            \id ->
                Encode.string id
                    |> Decode.decodeValue environmentIdDecoder
                    |> Expect.ok
        ]
