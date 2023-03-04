module Main exposing (..)

import Api
import Api.Endpoint as Endpoint exposing (AccessToken, Environment, Space)
import Browser
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Events
import Http
import InteropPorts
import Json.Decode as Decode
import Json.Encode as Encode
import RemoteData as RD exposing (RemoteData(..), WebData)



-- MODEL


type alias Model =
    { clientId : String
    , secretKey : String
    , accessToken : WebData AccessToken
    , environments : WebData (List Environment)
    , spaces : WebData (List Space)
    }


init : Decode.Value -> ( Model, Cmd Msg )
init flags =
    case InteropPorts.decodeFlags flags of
        Err _ ->
            ( Model "" "" NotAsked NotAsked NotAsked, Cmd.none )

        Ok _ ->
            ( Model "" "" NotAsked NotAsked NotAsked, Cmd.none )



-- UPDATE


type Msg
    = NoOp
      -- FORM
    | EnteredClientId String
    | EnteredSecretKey String
      -- HTTP
    | SendAuthRequest
    | GotAuthResponse (WebData AccessToken)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnteredClientId clientId ->
            ( { model | clientId = clientId }, Cmd.none )

        EnteredSecretKey secretKey ->
            ( { model | secretKey = secretKey }, Cmd.none )

        GotAuthResponse response ->
            ( { model | accessToken = response }, Cmd.none )

        SendAuthRequest ->
            let
                clientId =
                    model.clientId

                secretKey =
                    model.secretKey

                jsonBody =
                    Encode.object
                        [ ( "clientId", Encode.string clientId )
                        , ( "secret", Encode.string secretKey )
                        ]
                        |> Http.jsonBody
            in
            ( model, Api.post Endpoint.auth jsonBody GotAuthResponse Endpoint.authDecoder )

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


viewAuth : Model -> Html Msg
viewAuth model =
    case model.accessToken of
        NotAsked ->
            div [ Attr.class "" ]
                [ form
                    [ Attr.class ""
                    , Attr.method "POST"
                    , Events.onSubmit SendAuthRequest
                    ]
                    [ div [ Attr.class "grid grid-cols-2 gap-y-6 gap-x-8 sm:grid-cols-1" ]
                        [ div [ Attr.class "" ]
                            [ label
                                [ Attr.class "block text-sm font-semibold leading-6 text-gray-900"
                                , Attr.for "client-id"
                                ]
                                [ text "Client Id" ]
                            , div [ Attr.class "mt-2.5" ]
                                [ input
                                    [ mkTestAttribute "input-client-id"
                                    , Attr.autocomplete False
                                    , Attr.autofocus True
                                    , Attr.class "block w-full rounded-md border-0 py-2 px-3.5 text-sm leading-6 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600"
                                    , Attr.id "client-id"
                                    , Attr.name "client-id"
                                    , Events.onInput EnteredClientId
                                    ]
                                    []
                                ]
                            ]
                        , div [ Attr.class "" ]
                            [ label
                                [ Attr.class "block text-sm font-semibold leading-6 text-gray-900"
                                , Attr.for "secret-key"
                                ]
                                [ text "Secret" ]
                            , div [ Attr.class "mt-2.5" ]
                                [ input
                                    [ mkTestAttribute "input-secret-key"
                                    , Attr.class "block w-full rounded-md border-0 py-2 px-3.5 text-sm leading-6 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600"
                                    , Attr.name "secret-key"
                                    , Attr.id "secret-key"
                                    , Attr.autocomplete False
                                    , Attr.type_ "password"
                                    , Events.onInput EnteredSecretKey
                                    ]
                                    []
                                ]
                            ]
                        , button
                            [ mkTestAttribute "btn-auth-submit"
                            , Attr.type_ "submit"
                            ]
                            [ text "Authenticate" ]
                        ]
                    ]
                ]

        Loading ->
            div [] [ text "loading" ]

        Success _ ->
            viewMeta

        Failure _ ->
            div [] [ text "failure :(" ]


viewMeta : Html msg
viewMeta =
    div [ Attr.class "" ]
        [ div [ Attr.class "" ]
            [ h3 [ Attr.class "text-base font-semibold leading-6 text-gray-900" ] [ text "Applicat Information" ]
            , p [ Attr.class "" ] [ text "Personal details and application" ]
            ]
        ]


viewEventsTable : Html msg
viewEventsTable =
    div [ Attr.class "px-4 sm:px-6 lg:px-8" ]
        [ div [ Attr.class "sm:flex sm:items-center" ]
            [ div [ Attr.class "sm:flex-auto" ]
                [ h1 [ Attr.class "text-base font-semibold leading-6 text-gray-900" ] [ text "Events" ]
                , p [ Attr.class "mt-2 text-sm text-gray-700" ] [ text "Events are streamed in real-time" ]
                ]
            , div [ Attr.class "mt-4 sm:mt-0 sm:ml-16 sm:flex-none" ]
                [ button [ Attr.class "block rounded-md bg-indigo-600 py-2 px-3 text-center text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600" ] [ text "Export" ]
                ]
            ]
        , div [ Attr.class "mt-8 flow-root" ]
            [ div [ Attr.class "-my-2 -mx-4 overflow-x-auto sm:-mx-6 lg:-mx-8" ]
                [ div [ Attr.class "inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8" ]
                    [ table [ Attr.class "min-w-full divide-y divide-gray-300" ]
                        [ thead [ Attr.class "" ]
                            [ tr [ Attr.class "" ]
                                [ th [ Attr.class "whitespace-nowrap py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-0", Attr.scope "col" ] [ text "Arrow" ]
                                , th [ Attr.class "whitespace-nowrap py-3.5 px-2 text-left text-sm font-semibold text-gray-900", Attr.scope "col" ] [ text "Icon" ]
                                , th [ Attr.class "whitespace-nowrap py-3.5 px-2 text-left text-sm font-semibold text-gray-900", Attr.scope "col" ] [ text "Created At" ]
                                , th [ Attr.class "whitespace-nowrap py-3.5 px-2 text-left text-sm font-semibold text-gray-900", Attr.scope "col" ] [ text "Summary" ]
                                ]
                            ]
                        , tbody [ Attr.class "divide-y divide-gray-200 bg-white" ]
                            [ tr [ Attr.class "" ]
                                [ td [ Attr.class "whitespace-nowrap py-2 text-sm text-gray-500" ] [ text ">" ]
                                , td [ Attr.class "whitespace-nowrap py-2 px-2 text-sm text-gray-500" ] [ text "W" ]
                                , td [ Attr.class "whitespace-nowrap py-2 px-2 text-sm text-gray-500" ] [ text "2019-12-17 10:10:37.951 MST" ]
                                , td [ Attr.class "whitespace-nowrap py-2 px-2 text-sm text-gray-500" ] [ text "Sum helpful summary text" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "Hello"
    , body =
        [ div [ Attr.class "" ]
            [ section [ Attr.class "", mkTestAttribute "section-auth" ] [ viewAuth model ]

            -- , section [ Attr.class "", mkTestAttribute "section-meta" ] [ viewMeta ]
            -- , section [ Attr.class "", mkTestAttribute "section-table" ] [ viewEventsTable ]
            ]
        ]
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
