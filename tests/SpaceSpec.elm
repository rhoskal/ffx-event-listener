module SpaceSpec exposing (..)

import Expect
import Fuzz exposing (string)
import Json.Decode as Decode
import Json.Encode as Encode
import Space exposing (spaceDecoder)
import Test exposing (..)


suite : Test
suite =
    describe "[Space]"
        [ fuzz3 string string string "spaceDecoder maps required fields to a Space" <|
            \id spaceConfigId environmentId ->
                [ ( "id", Encode.string id )
                , ( "spaceConfigId", Encode.string spaceConfigId )
                , ( "environmentId", Encode.string environmentId )
                ]
                    |> Encode.object
                    |> Decode.decodeValue spaceDecoder
                    |> Expect.ok
        , fuzz3 string string string "spaceDecoder fails to map required fields to a Space" <|
            \id spaceConfigId environmentId ->
                [ ( "id", Encode.string id )
                , ( "spaceConfigId", Encode.string spaceConfigId )
                , ( "environmentid", Encode.string environmentId )
                ]
                    |> Encode.object
                    |> Decode.decodeValue spaceDecoder
                    |> Expect.err

        -- , fuzz2 string string "spacesDecoder maps required fields to a List Space" <|
        --     \id environmentId ->
        --         [ ( "data"
        --           , [ ( "id", Encode.string id )
        --             , ( "environmentId", Encode.string environmentId )
        --             ]
        --           )
        --         ]
        --             |> Encode.object
        --             |> Decode.decodeValue spacesDecoder
        --             |> Expect.ok
        ]
