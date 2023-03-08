module UtilsSpec exposing (..)

import Html
import Html.Attributes as Attr
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector as Selector
import Utils exposing (mkTestAttribute)


suite : Test
suite =
    describe "attributes"
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
