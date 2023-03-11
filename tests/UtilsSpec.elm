module UtilsSpec exposing (..)

import Expect
import Html
import Html.Attributes as Attr
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector as Selector
import Time
import Utils exposing (mkTestAttribute, posixToString)


suite : Test
suite =
    describe "[Utils]"
        [ describe "attributes"
            [ test "data-testid" <|
                \() ->
                    Html.div [ mkTestAttribute "foo-bar" ]
                        [ Html.text "test node" ]
                        |> Query.fromHtml
                        |> Query.has
                            [ Selector.attribute <|
                                Attr.attribute "data-testid" "foo-bar"
                            ]
            ]
        , describe "time"
            [ test "posixToString" <|
                \() ->
                    posixToString (Time.millisToPosix 0) Time.utc
                        |> Expect.equal "1970 Jan 1st 00:00:00.0"
            ]
        ]
