module UtilsSpec exposing (..)

import Expect
import Html
import Html.Attributes as Attr
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector as Selector
import Time
import Utils exposing (mkTestAttribute)


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
        ]
