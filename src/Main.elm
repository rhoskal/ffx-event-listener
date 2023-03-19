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
import Session
import Skeleton
import Url
import Viewer



-- MODEL


type Model
    = NotFound Session.Session
    | Redirect Session.Session
    | Home Home.Model
    | Login Login.Model
    | Stats Stats.Model


init : D.Value -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    case InteropPorts.decodeFlags flags of
        Err _ ->
            let
                maybeViewer : Maybe Viewer.Viewer
                maybeViewer =
                    Nothing

                model : Model
                model =
                    Redirect (Session.fromViewer navKey maybeViewer)
            in
            stepUrl url model

        Ok { accessToken } ->
            let
                maybeViewer : Maybe Viewer.Viewer
                maybeViewer =
                    Maybe.map Viewer.wrap accessToken

                model : Model
                model =
                    Redirect (Session.fromViewer navKey maybeViewer)
            in
            stepUrl url model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        NotFound _ ->
            Sub.none

        Redirect _ ->
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
    | GotSession Session.Session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl (Session.navKey <| session model) (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , InteropDefinitions.OpenExternalLink url
                        |> InteropPorts.fromElm
                    )

        UrlChanged url ->
            stepUrl url model

        HomeMsg subMsg ->
            case model of
                Home home ->
                    stepHome (Home.update subMsg home)

                _ ->
                    ( model, Cmd.none )

        LoginMsg subMsg ->
            case model of
                Login login ->
                    stepLogin (Login.update subMsg login)

                _ ->
                    ( model, Cmd.none )

        StatsMsg subMsg ->
            case model of
                Stats stats ->
                    stepStats (Stats.update subMsg stats)

                _ ->
                    ( model, Cmd.none )

        GotSession session ->
            stepUrl


stepHome : ( Home.Model, Cmd Home.Msg ) -> ( Model, Cmd Msg )
stepHome ( home, cmds ) =
    ( Home home, Cmd.map HomeMsg cmds )


stepLogin : ( Login.Model, Cmd Login.Msg ) -> ( Model, Cmd Msg )
stepLogin ( login, cmds ) =
    ( Login login, Cmd.map LoginMsg cmds )


stepStats : ( Stats.Model, Cmd Stats.Msg ) -> ( Model, Cmd Msg )
stepStats ( stats, cmds ) =
    ( Stats stats, Cmd.map StatsMsg cmds )


stepUrl : Url.Url -> Model -> ( Model, Cmd Msg )
stepUrl url model =
    let
        maybeRoute : Maybe Route.Route
        maybeRoute =
            Route.fromUrl url

        session_ : Session.Session
        session_ =
            session model
    in
    case maybeRoute of
        Just Route.Home ->
            stepHome (Home.init session_)

        Just Route.Login ->
            stepLogin (Login.init session_)

        Just Route.Logout ->
            ( model, Cmd.none )

        Just Route.Stats ->
            stepStats (Stats.init session_)

        Nothing ->
            ( NotFound session_, Cmd.none )


session : Model -> Session.Session
session model =
    case model of
        NotFound session_ ->
            session_

        Redirect session_ ->
            session_

        Home home ->
            Home.session home

        Login login ->
            Login.session login

        Stats stats ->
            Stats.session stats



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
    case model of
        NotFound _ ->
            Skeleton.view Skeleton.Other NotFound.view

        Redirect _ ->
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
