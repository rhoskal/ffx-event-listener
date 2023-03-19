module Skeleton exposing (Skeleton(..), view)

import Browser
import Html exposing (..)
import Html.Attributes as Attr
import Route


type Skeleton
    = Home
    | Other
    | Stats



-- PUBLIC


view : Skeleton -> { title : String, content : Html msg } -> Browser.Document msg
view page { title, content } =
    { title = title ++ " - Crispy Critters"
    , body = [ viewNav page, content ]
    }



-- PRIVATE


viewNav : Skeleton -> Html msg
viewNav page =
    let
        linkTo =
            navbarLink page
    in
    nav [ Attr.class "" ]
        [ ul [ Attr.class "" ]
            [ linkTo Route.Home [ text "Home" ]
            , linkTo Route.Stats [ text "Stats" ]
            ]
        ]


navbarLink : Skeleton -> Route.Route -> List (Html msg) -> Html msg
navbarLink page route linkContent =
    li
        [ Attr.classList
            [ ( "active", isActive page route )
            ]
        ]
        [ a
            [ Attr.class ""
            , Route.href route
            ]
            linkContent
        ]


isActive : Skeleton -> Route.Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Home, Route.Home ) ->
            True

        ( Stats, Route.Stats ) ->
            True

        _ ->
            False
