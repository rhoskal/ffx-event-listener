module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html
import InteropDefinitions
import InteropPorts
import Json.Decode as D
import Page.Home as Home
import Page.Login as Login
import Page.NotFound as NotFound
import Page.Stats as Stats
import Route
import Skeleton
import Url
import Viewer



-- MODEL


type alias Model =
    { navKey : Nav.Key
    , page : Page
    , viewer : Maybe Viewer.Viewer
    }


type Page
    = NotFound
    | Home Home.Model
    | Login Login.Model
    | Stats Stats.Model


init : D.Value -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    case InteropPorts.decodeFlags flags of
        Err _ ->
            stepUrl url
                { navKey = navKey
                , page = NotFound
                , viewer = Nothing
                }

        Ok { accessToken } ->
            let
                maybeViewer =
                    Maybe.map Viewer.wrap accessToken
            in
            stepUrl url
                { navKey = navKey
                , page = NotFound
                , viewer = maybeViewer
                }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        NotFound ->
            Sub.none

        Home home ->
            Sub.map HomeMsg (Home.subscriptions home)

        Login login ->
            Sub.map LoginMsg (Login.subscriptions login)

        Stats stats ->
            Sub.map StatsMsg (Stats.subscriptions stats)



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Home.Msg
    | LoginMsg Login.Msg
    | StatsMsg Stats.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , InteropDefinitions.OpenExternalLink url
                        |> InteropPorts.fromElm
                    )

        UrlChanged url ->
            stepUrl url model

        HomeMsg subMsg ->
            case model.page of
                Home home ->
                    stepHome model (Home.update subMsg home)

                _ ->
                    ( model, Cmd.none )

        LoginMsg subMsg ->
            case model.page of
                Login login ->
                    stepLogin model (Login.update subMsg login)

                _ ->
                    ( model, Cmd.none )

        StatsMsg subMsg ->
            case model.page of
                Stats stats ->
                    stepStats model (Stats.update subMsg stats)

                _ ->
                    ( model, Cmd.none )


stepHome : Model -> ( Home.Model, Cmd Home.Msg ) -> ( Model, Cmd Msg )
stepHome model ( home, cmds ) =
    ( { model | page = Home home }, Cmd.map HomeMsg cmds )


stepLogin : Model -> ( Login.Model, Cmd Login.Msg ) -> ( Model, Cmd Msg )
stepLogin model ( login, cmds ) =
    ( { model | page = Login login }, Cmd.map LoginMsg cmds )


stepStats : Model -> ( Stats.Model, Cmd Stats.Msg ) -> ( Model, Cmd Msg )
stepStats model ( stats, cmds ) =
    ( { model | page = Stats stats }, Cmd.map StatsMsg cmds )


stepUrl : Url.Url -> Model -> ( Model, Cmd Msg )
stepUrl url model =
    let
        maybeRoute : Maybe Route.Route
        maybeRoute =
            Route.fromUrl url
    in
    case maybeRoute of
        Just Route.Home ->
            stepHome model Home.init

        Just Route.Login ->
            stepLogin model Login.init

        Just Route.Logout ->
            ( model, Cmd.none )

        Just Route.Stats ->
            stepStats model Stats.init

        Nothing ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        viewPage page toMsg content =
            let
                { title, body } =
                    Skeleton.view page content
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model.page of
        NotFound ->
            Skeleton.view Skeleton.Other NotFound.view

        Home home ->
            viewPage Skeleton.Home HomeMsg (Home.view home)

        Login login ->
            viewPage Skeleton.Other LoginMsg (Login.view login)

        Stats stats ->
            viewPage Skeleton.Stats StatsMsg (Stats.view stats)



-- MAIN


main : Program D.Value Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
