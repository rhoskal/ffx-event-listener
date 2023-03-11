module IconSpec exposing (..)

import Html.Attributes as Attr
import Icon
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "[Icon]"
        [ test "defaults" <|
            \() ->
                Icon.defaults
                    |> Icon.arrowRight
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.attribute <|
                            Attr.attribute "fill" "currentColor"
                        , Selector.attribute <|
                            Attr.attribute "height" "0"
                        , Selector.attribute <|
                            Attr.attribute "width" "0"
                        ]
        , test "withColor" <|
            \() ->
                Icon.defaults
                    |> Icon.withColor "#4F46E5"
                    |> Icon.arrowRight
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.attribute <|
                            Attr.attribute "fill" "#4F46E5"
                        ]
        , test "withHeight" <|
            \() ->
                Icon.defaults
                    |> Icon.withHeight 42
                    |> Icon.arrowRight
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.attribute <|
                            Attr.attribute "height" "42"
                        ]
        , test "withWidth" <|
            \() ->
                Icon.defaults
                    |> Icon.withWidth 42
                    |> Icon.arrowRight
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.attribute <|
                            Attr.attribute "width" "42"
                        ]
        , test "withSize" <|
            \() ->
                Icon.defaults
                    |> Icon.withSize 42
                    |> Icon.arrowRight
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.attribute <|
                            Attr.attribute "width" "42"
                        , Selector.attribute <|
                            Attr.attribute "height" "42"
                        ]
        ]
