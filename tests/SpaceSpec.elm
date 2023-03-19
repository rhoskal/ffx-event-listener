module SpaceSpec exposing (..)

import Expect
import Fuzz exposing (string)
import Json.Decode as D
import Json.Encode as E
import Space
import Test exposing (..)


suite : Test
suite =
    describe "[Space]"
        [ fuzz3 string string string "spaceDecoder maps required fields to a Space" <|
            \id spaceConfigId environmentId ->
                [ ( "id", E.string id )
                , ( "spaceConfigId", E.string spaceConfigId )
                , ( "environmentId", E.string environmentId )
                ]
                    |> E.object
                    |> D.decodeValue Space.decoder
                    |> Expect.ok
        , fuzz3 string string string "spaceDecoder fails to map required fields to a Space" <|
            \id spaceConfigId environmentId ->
                [ ( "id", E.string id )
                , ( "spaceConfigId", E.string spaceConfigId )
                , ( "environmentid", E.string environmentId )
                ]
                    |> E.object
                    |> D.decodeValue Space.decoder
                    |> Expect.err

        -- , fuzz2 string string "spacesDecoder maps required fields to a List Space" <|
        --     \id environmentId ->
        --         [ ( "data"
        --           , [ ( "id", E.string id )
        --             , ( "environmentId", E.string environmentId )
        --             ]
        --           )
        --         ]
        --             |> E.object
        --             |> D.decodeValue Spaces.decoder
        --             |> Expect.ok
        ]
