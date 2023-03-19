module Page.Home exposing
    ( Model
    , Msg
    , init
    , session
    , subscriptions
    , update
    , view
    )

import Html exposing (..)
import Html.Attributes as Attr
import Session



-- MODEL


type alias Model =
    { session : Session.Session
    }


init : Session.Session -> ( Model, Cmd Msg )
init session_ =
    ( { session = session_ }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- UPDATE


type Msg
    = NoOp
    | GotSession Session.Session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GotSession session_ ->
            ( { session = session_ }, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html msg }
view _ =
    { title = "Home Page"
    , content =
        main_ [ Attr.class "", Attr.tabindex -1 ]
            [ div [] [ text "Home Page" ]
            ]
    }


session : Model -> Session.Session
session model =
    model.session
