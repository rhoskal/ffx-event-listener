module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Events
import InteropPorts
import Json.Decode as Decode
import RemoteData as RD exposing (RemoteData(..), WebData)



-- MODEL


type alias Model =
    { clientId : String
    , secret : String
    , accessToken : Maybe String
    , environments : WebData (List EnvironmentData)
    , spaces : WebData (List SpaceData)
    }


type alias EnvironmentData =
    { id : String
    , accountId : String
    , name : String
    }


type alias SpaceData =
    { id : String
    , workbooksCount : Maybe Int
    , filesCount : Maybe Int
    , createdByUserId : Maybe String
    , createdAt : Maybe String
    , environmentId : String
    , name : Maybe String
    }


init : Decode.Value -> ( Model, Cmd Msg )
init flags =
    case InteropPorts.decodeFlags flags of
        Err _ ->
            ( Model "" "" Nothing NotAsked NotAsked, Cmd.none )

        Ok _ ->
            ( Model "" "" Nothing NotAsked NotAsked, Cmd.none )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


mkTestAttribute : String -> Attribute msg
mkTestAttribute key =
    Attr.attribute "data-testid" (String.toLower key)


viewAuth : Html msg
viewAuth =
    div [ Attr.class "" ] []


viewMeta : Html msg
viewMeta =
    div [ Attr.class "" ] []


viewEventsTable : Html msg
viewEventsTable =
    div [ Attr.class "" ] []


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
