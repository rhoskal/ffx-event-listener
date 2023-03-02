module Main exposing (..)

import Browser
import Html
import Json.Decode as Decode



-- MODEL


type alias Model =
    {}


init : Decode.Value -> ( Model, Cmd Msg )
init flags =
    ( {}, Cmd.none )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Hello"
    , body = []
    }



-- MAIN


main : Program Decode.Value Model Msg
main =
    Browser.document
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
