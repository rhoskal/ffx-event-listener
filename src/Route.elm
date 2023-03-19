module Route exposing (Route(..), fromUrl, href)

import Html
import Html.Attributes as Attr
import Url
import Url.Parser as Parser



-- ROUTING


type Route
    = Home
    | Login
    | Logout
    | Stats


parser : Parser.Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map Login (Parser.s "login")
        , Parser.map Logout (Parser.s "logout")
        , Parser.map Stats (Parser.s "stats")
        ]



-- PUBLIC


href : Route -> Html.Attribute msg
href =
    Attr.href << routeToString


fromUrl : Url.Url -> Maybe Route
fromUrl url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Parser.parse parser



-- INTERNAL


routeToString : Route -> String
routeToString page =
    "#/" ++ String.join "/" (routeToPieces page)


routeToPieces : Route -> List String
routeToPieces page =
    case page of
        Home ->
            []

        Login ->
            [ "login" ]

        Logout ->
            [ "logout" ]

        Stats ->
            [ "stats" ]
