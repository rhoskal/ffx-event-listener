module Main exposing (..)

import Api
import Api.Endpoint as Endpoint
    exposing
        ( AccessToken
        , Environment
        , Space
        , SubscriptionCreds
        )
import Browser
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Events
import Http
import InteropDefinitions
import InteropPorts
import Json.Decode as Decode
import Json.Encode as Encode
import RemoteData as RD exposing (RemoteData(..), WebData)
import Svg exposing (g, path, svg)
import Svg.Attributes as SvgAttr



-- MODEL


type alias Model =
    { clientId : String
    , secretKey : String
    , accessToken : WebData AccessToken
    , environments : WebData (List Environment)
    , spaces : WebData (List Space)
    , selectedEnvironment : Maybe Environment
    , selectedSpace : Maybe Space
    , events : List String
    , subscriptionCreds : WebData SubscriptionCreds
    }


initialModel : Model
initialModel =
    { clientId = ""
    , secretKey = ""
    , accessToken = NotAsked
    , environments = NotAsked
    , spaces = NotAsked
    , selectedEnvironment = Nothing
    , selectedSpace = Nothing
    , events = []
    , subscriptionCreds = NotAsked
    }


init : Decode.Value -> ( Model, Cmd Msg )
init flags =
    case InteropPorts.decodeFlags flags of
        Err _ ->
            ( initialModel, Cmd.none )

        Ok _ ->
            ( initialModel, Cmd.none )



-- UPDATE


type Msg
    = Reset
    | OpenExternalLink String
      -- Form
    | EnteredClientId String
    | EnteredSecretKey String
    | SelectedEnvironment Environment
    | SelectedSpace Space
      -- Http
    | SendAuthRequest
    | GotAuthResponse (WebData AccessToken)
    | GotEnvironmentsResponse (WebData (List Environment))
    | GotSpacesResponse (WebData (List Space))
    | GotSubscriptionCredsResponse (WebData SubscriptionCreds)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Reset ->
            ( initialModel, Cmd.none )

        OpenExternalLink externalLink ->
            ( model
            , externalLink
                |> InteropDefinitions.OpenExternalLink
                |> InteropPorts.fromElm
            )

        EnteredClientId clientId ->
            ( { model | clientId = clientId }, Cmd.none )

        EnteredSecretKey secretKey ->
            ( { model | secretKey = secretKey }, Cmd.none )

        SelectedEnvironment env ->
            ( { model | selectedEnvironment = Just env }
            , Api.get (Endpoint.listSpaces env.id) GotSpacesResponse Endpoint.spacesDecoder
            )

        SelectedSpace space ->
            ( { model | selectedSpace = Just space }
            , Api.get (Endpoint.getSubscriptionCreds space.id) GotSubscriptionCredsResponse Endpoint.subscriptionCredsDecoder
            )

        GotAuthResponse response ->
            ( { model | accessToken = response }
            , Api.get Endpoint.listEnvironments GotEnvironmentsResponse Endpoint.environmentsDecoder
            )

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

        GotEnvironmentsResponse response ->
            ( { model | environments = response }, Cmd.none )

        GotSpacesResponse response ->
            ( { model | spaces = response }, Cmd.none )

        GotSubscriptionCredsResponse response ->
            ( { model | subscriptionCreds = response }, Cmd.none )



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
            div [] [ text "success!" ]

        Failure _ ->
            div [] [ text "failure :(" ]


viewMeta : Environment -> Space -> Html Msg
viewMeta selectedEnvironment selectedSpace =
    let
        spaceName : String
        spaceName =
            Maybe.withDefault ("[Unnamed — " ++ selectedSpace.id ++ "]") selectedSpace.name

        environmentName : String
        environmentName =
            selectedEnvironment.name

        createdAt : String
        createdAt =
            Maybe.withDefault "[Date Unknown]" selectedSpace.createdAt

        createdBy : String
        createdBy =
            Maybe.withDefault "@username" selectedSpace.createdByUserName
    in
    div [ Attr.class "flex items-center justify-between py-5 px-4" ]
        [ div [ Attr.class "flex-col" ]
            [ h2 [ Attr.class "text-2xl font-bold leading-7 text-gray-900" ]
                [ text spaceName
                ]
            , div [ Attr.class "flex mt-1 space-x-6" ]
                [ div [ Attr.class "inline-flex items-center text-sm text-gray-300" ]
                    [ svg
                        [ SvgAttr.class "h-5 w-5 mr-1.5"
                        , SvgAttr.version "1.1"
                        , SvgAttr.viewBox "0 0 512 512"
                        , SvgAttr.fill "currentColor"
                        ]
                        [ path [ SvgAttr.d "M379.65,265.79c0-19.92-8.95-38.31-24.09-53.2a24.41,24.41,0,0,1-7-21.67,86.25,86.25,0,0,0,1.28-14.82c0-49.54-42-89.7-93.86-89.7s-93.86,40.16-93.86,89.7a86.25,86.25,0,0,0,1.28,14.82,24.41,24.41,0,0,1-7,21.67c-15.14,14.89-24.09,33.28-24.09,53.2,0,47.34,50.56,86.11,114.65,89.45v39.21H174.35v18H334.42v-18H265V355.24C329.09,351.9,379.65,313.13,379.65,265.79ZM247,355.23V302.79l-32-31.72,12.67-12.79L256,286.37l28.34-28.09L297,271.07l-32,31.72v52.44Z" ] [] ]
                    , text environmentName
                    ]
                , div [ Attr.class "inline-flex items-center text-sm text-gray-300" ]
                    [ svg
                        [ SvgAttr.class "h-5 w-5 mr-1.5"
                        , SvgAttr.version "1.1"
                        , SvgAttr.viewBox "0 0 20 20"
                        , SvgAttr.fill "currentColor"
                        ]
                        [ path [ SvgAttr.d "M5.75 2a.75.75 0 01.75.75V4h7V2.75a.75.75 0 011.5 0V4h.25A2.75 2.75 0 0118 6.75v8.5A2.75 2.75 0 0115.25 18H4.75A2.75 2.75 0 012 15.25v-8.5A2.75 2.75 0 014.75 4H5V2.75A.75.75 0 015.75 2zm-1 5.5c-.69 0-1.25.56-1.25 1.25v6.5c0 .69.56 1.25 1.25 1.25h10.5c.69 0 1.25-.56 1.25-1.25v-6.5c0-.69-.56-1.25-1.25-1.25H4.75z" ] []
                        ]
                    , text createdAt
                    ]
                , div [ Attr.class "inline-flex items-center text-sm text-gray-300" ]
                    [ svg
                        [ SvgAttr.class "h-5 w-5 mr-1.5"
                        , SvgAttr.version "1.1"
                        , SvgAttr.viewBox "0 0 24 24"
                        , SvgAttr.fill "currentColor"
                        ]
                        [ path [ SvgAttr.d "M12 12.25C11.2583 12.25 10.5333 12.0301 9.91661 11.618C9.29993 11.206 8.81928 10.6203 8.53545 9.93506C8.25163 9.24984 8.17736 8.49584 8.32206 7.76841C8.46675 7.04098 8.8239 6.3728 9.34835 5.84835C9.8728 5.3239 10.541 4.96675 11.2684 4.82206C11.9958 4.67736 12.7498 4.75162 13.4351 5.03545C14.1203 5.31928 14.706 5.79993 15.118 6.41661C15.5301 7.0333 15.75 7.75832 15.75 8.5C15.75 9.49456 15.3549 10.4484 14.6517 11.1517C13.9484 11.8549 12.9946 12.25 12 12.25ZM12 6.25C11.555 6.25 11.12 6.38196 10.75 6.62919C10.38 6.87643 10.0916 7.22783 9.92127 7.63896C9.75098 8.0501 9.70642 8.5025 9.79323 8.93895C9.88005 9.37541 10.0943 9.77632 10.409 10.091C10.7237 10.4057 11.1246 10.62 11.561 10.7068C11.9975 10.7936 12.4499 10.749 12.861 10.5787C13.2722 10.4084 13.6236 10.12 13.8708 9.75003C14.118 9.38002 14.25 8.94501 14.25 8.5C14.25 7.90326 14.0129 7.33097 13.591 6.90901C13.169 6.48705 12.5967 6.25 12 6.25Z" ] []
                        , path [ SvgAttr.d "M19 19.25C18.8019 19.2474 18.6126 19.1676 18.4725 19.0275C18.3324 18.8874 18.2526 18.6981 18.25 18.5C18.25 16.55 17.19 15.25 12 15.25C6.81 15.25 5.75 16.55 5.75 18.5C5.75 18.6989 5.67098 18.8897 5.53033 19.0303C5.38968 19.171 5.19891 19.25 5 19.25C4.80109 19.25 4.61032 19.171 4.46967 19.0303C4.32902 18.8897 4.25 18.6989 4.25 18.5C4.25 13.75 9.68 13.75 12 13.75C14.32 13.75 19.75 13.75 19.75 18.5C19.7474 18.6981 19.6676 18.8874 19.5275 19.0275C19.3874 19.1676 19.1981 19.2474 19 19.25Z" ] []
                        ]
                    , text createdBy
                    ]
                ]
            ]
        , div [ Attr.class "flex" ]
            [ div [ Attr.class "mr-2" ]
                [ button
                    [ mkTestAttribute "btn-view-space"
                    , Attr.class "inline-flex items-center rounded-md px-3 py-2 text-sm font-semibold shadow-sm"
                    , Events.onClick (OpenExternalLink "https://dashboard.spaces.com/space/")
                    ]
                    [ svg
                        [ SvgAttr.class "h-5 w-5 mr-1.5"
                        , SvgAttr.version "1.1"
                        , SvgAttr.viewBox "0 0 20 20"
                        , SvgAttr.fill "currentColor"
                        ]
                        [ path [ SvgAttr.d "M12.232 4.232a2.5 2.5 0 013.536 3.536l-1.225 1.224a.75.75 0 001.061 1.06l1.224-1.224a4 4 0 00-5.656-5.656l-3 3a4 4 0 00.225 5.865.75.75 0 00.977-1.138 2.5 2.5 0 01-.142-3.667l3-3z" ] []
                        , path [ SvgAttr.d "M11.603 7.963a.75.75 0 00-.977 1.138 2.5 2.5 0 01.142 3.667l-3 3a2.5 2.5 0 01-3.536-3.536l1.225-1.224a.75.75 0 00-1.061-1.06l-1.224 1.224a4 4 0 105.656 5.656l3-3a4 4 0 00-.225-5.865z" ] []
                        ]
                    , text "View"
                    ]
                ]
            , div [ Attr.class "" ]
                [ button
                    [ mkTestAttribute "btn-reset"
                    , Attr.class "inline-flex items-center rounded-md px-3 py-2 text-sm font-semibold shadow-sm"
                    , Events.onClick Reset
                    ]
                    [ svg
                        [ SvgAttr.class "h-5 w-5 mr-1.5"
                        , SvgAttr.version "1.1"
                        , SvgAttr.viewBox "0 0 21 21"
                        , SvgAttr.fill "currentColor"
                        ]
                        [ g
                            [ SvgAttr.fill "none"
                            , SvgAttr.fillRule "evenodd"
                            , SvgAttr.stroke "currentColor"
                            , SvgAttr.strokeLinecap "round"
                            , SvgAttr.strokeLinejoin "round"
                            , SvgAttr.transform "translate(2 2)"
                            ]
                            [ path [ SvgAttr.d "m4.5 1.5c-2.4138473 1.37729434-4 4.02194088-4 7 0 4.418278 3.581722 8 8 8s8-3.581722 8-8-3.581722-8-8-8" ] []
                            , path [ SvgAttr.d "m4.5 5.5v-4h-4" ] []
                            ]
                        ]
                    , text "Reset"
                    ]
                ]
            ]
        ]


viewEventsTable : Model -> Html msg
viewEventsTable _ =
    div [ Attr.class "px-4" ]
        [ div [ Attr.class "flex items-center" ]
            [ div [ Attr.class "flex-auto" ]
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
    let
        env : Environment
        env =
            Environment "us_env_GHasdfyU" "us_acc_FBClpjku" "Some Env Name"

        space : Space
        space =
            Space "us_sp_UxfreSbn" Nothing Nothing Nothing (Just "10 Jan 2023") "us_env_GHasdfyU" Nothing
    in
    { title = "Hello"
    , body =
        [ div [ Attr.class "" ]
            [ section [ Attr.class "", mkTestAttribute "section-events" ]
                [ viewMeta env space
                , viewEventsTable model
                ]
            ]

        -- [ section [ Attr.class "", mkTestAttribute "section-auth" ] [ viewAuth model ]
        -- ]
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
