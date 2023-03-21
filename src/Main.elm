module Main exposing (..)

import Agent
import AgentId
import Api
import Browser
import Environment
import EnvironmentId
import EventDomain
import EventId
import EventTopic
import Html exposing (..)
import Html.Attributes as Attr
import Html.Attributes.Extra as AttrExtra
import Html.Events as Events
import Html.Extra
import Icon
import InteropDefinitions
import InteropPorts
import Json.Decode as D
import Json.Encode as E
import LogEntry
import PubNub
import RemoteData as RD
import Space
import SpaceId
import Task
import Time
import Timestamp
import Utils exposing (mkTestAttribute)



-- MODEL


type alias Model =
    { clientId : String
    , secretKey : String
    , accessToken : RD.WebData Api.Cred
    , showSecret : Bool
    , showEnvironmentChoices : Bool
    , selectedEnvironment : Maybe Environment.Environment
    , environments : RD.WebData (List Environment.Environment)
    , showSpaceChoices : Bool
    , selectedSpace : Maybe Space.Space
    , spaces : RD.WebData (List Space.Space)
    , events : List PubNub.Event
    , subscriptionCreds : RD.WebData PubNub.SubscriptionCreds
    , expandedEventId : Maybe EventId.EventId
    , timeZone : Time.Zone
    , agents : RD.WebData (List Agent.Agent)
    , logEntries : RD.WebData (List LogEntry.LogEntry)
    }


defaults : Model
defaults =
    { clientId = ""
    , secretKey = ""
    , accessToken = RD.NotAsked
    , showSecret = False
    , showEnvironmentChoices = False
    , selectedEnvironment = Nothing
    , environments = RD.NotAsked
    , showSpaceChoices = False
    , selectedSpace = Nothing
    , spaces = RD.NotAsked
    , events = []
    , subscriptionCreds = RD.NotAsked
    , expandedEventId = Nothing
    , timeZone = Time.utc
    , agents = RD.NotAsked
    , logEntries = RD.NotAsked
    }


init : D.Value -> ( Model, Cmd Msg )
init flags =
    case InteropPorts.decodeFlags flags of
        Err _ ->
            ( defaults, Task.attempt TimeZone Time.here )

        Ok _ ->
            ( defaults, Task.attempt TimeZone Time.here )



-- UPDATE


type Msg
    = Reset
    | OpenExternalLink String
    | ClickedEvent EventId.EventId
    | ReceivedDomainEvent (Result D.Error InteropDefinitions.ToElm)
    | TimeZone (Result () Time.Zone)
      -- Form
    | EnteredClientId String
    | EnteredSecretKey String
    | ToggleShowSecret
    | SelectedEnvironment Environment.Environment
    | ToggleEnvironmentChoices
    | SelectedSpace Space.Space
    | ToggleSpaceChoices
      -- Http
    | SendAuthRequest
    | GotAuthResponse (RD.WebData Api.Cred)
    | GotEnvironmentsResponse (RD.WebData (List Environment.Environment))
    | GotSpacesResponse (RD.WebData (List Space.Space))
    | GotSubscriptionCredsResponse (RD.WebData PubNub.SubscriptionCreds)
    | GotAgentsResponse (RD.WebData (List Agent.Agent))
    | GotLogEntriesResponse (RD.WebData (List LogEntry.LogEntry))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Reset ->
            ( defaults, Cmd.none )

        OpenExternalLink externalLink ->
            ( model
            , externalLink
                |> InteropDefinitions.OpenExternalLink
                |> InteropPorts.fromElm
            )

        ClickedEvent incomingEventId ->
            case model.expandedEventId of
                Just previousEventId ->
                    if incomingEventId == previousEventId then
                        ( { model | expandedEventId = Nothing }, Cmd.none )

                    else
                        ( { model | expandedEventId = Just incomingEventId }, Cmd.none )

                Nothing ->
                    ( { model | expandedEventId = Just incomingEventId }, Cmd.none )

        ReceivedDomainEvent result ->
            case result of
                Ok (InteropDefinitions.PNDomainEvent domainEvent) ->
                    ( { model | events = domainEvent :: model.events }, Cmd.none )

                Err error ->
                    ( model
                    , D.errorToString error
                        |> InteropDefinitions.ReportIssue
                        |> InteropPorts.fromElm
                    )

        TimeZone result ->
            case result of
                Ok tz ->
                    ( { model | timeZone = tz }, Cmd.none )

                Err () ->
                    ( model, Cmd.none )

        EnteredClientId clientId ->
            ( { model | clientId = clientId }, Cmd.none )

        EnteredSecretKey secretKey ->
            ( { model | secretKey = secretKey }, Cmd.none )

        ToggleShowSecret ->
            ( { model | showSecret = not model.showSecret }, Cmd.none )

        SelectedEnvironment env ->
            let
                maybeCred : Maybe Api.Cred
                maybeCred =
                    RD.toMaybe model.accessToken
            in
            ( { model
                | selectedEnvironment = Just env
                , showEnvironmentChoices = False
              }
            , Cmd.batch
                [ Space.list env.id maybeCred GotSpacesResponse
                , Agent.list env.id maybeCred GotAgentsResponse
                , LogEntry.list env.id maybeCred GotLogEntriesResponse
                ]
            )

        ToggleEnvironmentChoices ->
            ( { model | showEnvironmentChoices = not model.showEnvironmentChoices }, Cmd.none )

        SelectedSpace space ->
            let
                maybeCred : Maybe Api.Cred
                maybeCred =
                    RD.toMaybe model.accessToken
            in
            ( { model
                | selectedSpace = Just space
                , showSpaceChoices = False
              }
            , PubNub.auth space.id maybeCred GotSubscriptionCredsResponse
            )

        ToggleSpaceChoices ->
            ( { model | showSpaceChoices = not model.showSpaceChoices }, Cmd.none )

        GotAuthResponse response ->
            let
                maybeCred : Maybe Api.Cred
                maybeCred =
                    RD.toMaybe response
            in
            case response of
                RD.Success _ ->
                    ( { model | accessToken = response }
                    , Environment.list maybeCred GotEnvironmentsResponse
                    )

                RD.Failure _ ->
                    ( { model | accessToken = response }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SendAuthRequest ->
            let
                clientId =
                    model.clientId

                secretKey =
                    model.secretKey
            in
            ( { model | accessToken = RD.Loading }, Api.login clientId secretKey GotAuthResponse )

        GotEnvironmentsResponse response ->
            ( { model | environments = response }, Cmd.none )

        GotSpacesResponse response ->
            ( { model | spaces = response }, Cmd.none )

        GotSubscriptionCredsResponse response ->
            ( { model | subscriptionCreds = response }
            , case response of
                RD.Success data ->
                    case model.selectedSpace of
                        Just space ->
                            { accountId = data.accountId
                            , spaceId = space.id
                            , subscribeKey = data.subscribeKey
                            , token = data.token
                            }
                                |> InteropDefinitions.UsePubNubCreds
                                |> InteropPorts.fromElm

                        Nothing ->
                            Cmd.none

                _ ->
                    Cmd.none
            )

        GotAgentsResponse response ->
            ( { model | agents = response }, Cmd.none )

        GotLogEntriesResponse response ->
            ( { model | logEntries = response }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    InteropPorts.toElm
        |> Sub.map ReceivedDomainEvent



-- VIEW


viewAuthForm : Model -> Html Msg
viewAuthForm model =
    form
        [ Attr.class ""
        , Events.onSubmit SendAuthRequest
        ]
        [ div [ Attr.class "grid grid-cols-2 gap-y-6 gap-x-8" ]
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
                [ div [ Attr.class "flex items-center justify-between" ]
                    [ label
                        [ Attr.class "block text-sm font-semibold leading-6 text-gray-900"
                        , Attr.for "secret-key"
                        ]
                        [ text "Secret" ]
                    , div
                        [ Attr.class "cursor-pointer text-gray-700"
                        , Events.onClick ToggleShowSecret
                        ]
                        [ if model.showSecret then
                            Icon.defaults
                                |> Icon.withSize 18
                                |> Icon.eyeClose

                          else
                            Icon.defaults
                                |> Icon.withSize 18
                                |> Icon.eyeOpen
                        ]
                    ]
                , div [ Attr.class "mt-2.5" ]
                    [ input
                        [ mkTestAttribute "input-secret-key"
                        , Attr.class "block w-full rounded-md border-0 py-2 px-3.5 text-sm leading-6 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600"
                        , Attr.name "secret-key"
                        , Attr.id "secret-key"
                        , Attr.autocomplete False
                        , Attr.type_
                            (if model.showSecret then
                                "text"

                             else
                                "password"
                            )
                        , Events.onInput EnteredSecretKey
                        ]
                        []
                    ]
                ]
            , button
                [ mkTestAttribute "btn-auth-submit"
                , Attr.class "col-span-full inline-flex items-center justify-center rounded-md px-3 py-2 text-sm font-semibold shadow-sm bg-indigo-600 text-white"
                , Attr.type_ "submit"
                ]
                [ text "Authenticate" ]
            ]
        ]


viewMeta :
    Environment.Environment
    -> Space.Space
    -> Time.Zone
    -> Html Msg
viewMeta selectedEnvironment selectedSpace timeZone =
    let
        spaceName : String
        spaceName =
            selectedSpace.name
                |> Maybe.andThen
                    (\name ->
                        if name == "" then
                            Just "[Unnamed]"

                        else
                            Just name
                    )
                |> Maybe.withDefault "[Unnamed]"

        environmentName : String
        environmentName =
            selectedEnvironment.name

        spaceConfigId : String
        spaceConfigId =
            selectedSpace.spaceConfigId

        createdAt : String
        createdAt =
            selectedSpace.createdAt
                |> Maybe.map (Timestamp.toString timeZone)
                |> Maybe.withDefault "[Date Unknown]"

        createdBy : String
        createdBy =
            Maybe.withDefault "@username" selectedSpace.createdByUserName
    in
    div [ Attr.class "flex items-center justify-between pt-10 pb-6" ]
        [ div [ Attr.class "flex-col" ]
            [ h2 [ Attr.class "text-2xl font-bold leading-7 text-gray-900" ]
                [ text spaceName ]
            , div [ Attr.class "flex mt-1 space-x-6" ]
                [ div [ Attr.class "inline-flex items-center text-sm text-gray-300" ]
                    [ span []
                        [ text environmentName ]
                    ]
                , div [ Attr.class "inline-flex items-center text-sm text-gray-300" ]
                    [ Icon.defaults
                        |> Icon.withSize 20
                        |> Icon.version
                    , span [ Attr.class "ml-1.5" ]
                        [ text spaceConfigId ]
                    ]
                , div [ Attr.class "inline-flex items-center text-sm text-gray-300" ]
                    [ Icon.defaults
                        |> Icon.withSize 20
                        |> Icon.calendar
                    , span [ Attr.class "ml-1.5" ]
                        [ text createdAt ]
                    ]
                , div [ Attr.class "inline-flex items-center text-sm text-gray-300" ]
                    [ Icon.defaults
                        |> Icon.withSize 20
                        |> Icon.user
                    , span [ Attr.class "ml-1.5" ]
                        [ text createdBy ]
                    ]
                ]
            ]
        , div [ Attr.class "flex" ]
            [ div [ Attr.class "mr-2" ]
                [ button
                    [ mkTestAttribute "btn-view-space"
                    , Attr.class "inline-flex items-center rounded-md px-3 py-2 text-sm font-semibold shadow-sm"
                    , Events.onClick (OpenExternalLink <| "https://spaces.flatfile.com/space/" ++ SpaceId.toString selectedSpace.id)
                    ]
                    [ Icon.defaults
                        |> Icon.withSize 20
                        |> Icon.chainlink
                    , span [ Attr.class "ml-1.5" ]
                        [ text "View" ]
                    ]
                ]
            , div [ Attr.class "" ]
                [ button
                    [ mkTestAttribute "btn-reset"
                    , Attr.class "inline-flex items-center rounded-md px-3 py-2 text-sm font-semibold shadow-sm"
                    , Events.onClick Reset
                    ]
                    [ Icon.defaults
                        |> Icon.withSize 20
                        |> Icon.resetCircle
                    , span [ Attr.class "ml-1.5" ]
                        [ text "Reset" ]
                    ]
                ]
            ]
        ]


viewSelectEnvironment : Model -> Html Msg
viewSelectEnvironment model =
    case model.environments of
        RD.NotAsked ->
            div [ Attr.class "w-full" ]
                [ text "Not Asked" ]

        RD.Loading ->
            div [ Attr.class "w-full" ]
                [ text "Loading..." ]

        RD.Success environments ->
            div [ Attr.class "w-full" ]
                [ label
                    [ Attr.class "block text-sm font-semibold leading-6 text-gray-900"
                    , Attr.id "listbox-environments-label"
                    ]
                    [ text "Environment" ]
                , div [ Attr.class "relative mt-2" ]
                    [ button
                        [ Attr.class "relative w-full hover:cursor-pointer rounded-md bg-white py-1.5 pl-3 pr-10 text-left text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-500 sm:text-sm sm:leading-6"
                        , Attr.attribute "aria-haspopup" "listbox"
                        , AttrExtra.attributeIf model.showEnvironmentChoices <| Attr.attribute "aria-expanded" "true"
                        , Attr.attribute "aria-labelledby" "listbox-environments-label"
                        , Events.onClick ToggleEnvironmentChoices
                        ]
                        [ span [ Attr.class "inline-flex w-full truncate" ]
                            [ span [ Attr.class "truncate select-none" ]
                                [ Maybe.map .name model.selectedEnvironment
                                    |> Maybe.withDefault "Select..."
                                    |> text
                                ]
                            , span [ Attr.class "ml-2 truncate text-gray-500" ]
                                [ Maybe.map (.id >> EnvironmentId.toString) model.selectedEnvironment
                                    |> Maybe.withDefault ""
                                    |> text
                                ]
                            ]
                        , span [ Attr.class "pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2 text-gray-400" ]
                            [ Icon.defaults
                                |> Icon.withSize 20
                                |> Icon.selectArrows
                            ]
                        ]
                    , ul
                        [ Attr.class "absolute z-10 mt-1 max-h-60 w-full overflow-auto rounded-md bg-white py-1 text-base shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none sm:text-sm"
                        , Attr.classList [ ( "hidden", not model.showEnvironmentChoices ) ]
                        , Attr.tabindex -1
                        , Attr.attribute "role" "listbox"
                        , Attr.attribute "aria-labelledby" "listbox-environments-label"
                        , Attr.attribute "aria-activedescendant" "listbox-option-0"
                        ]
                        (List.indexedMap
                            (\idx env ->
                                let
                                    attrId : String
                                    attrId =
                                        "listbox-option-" ++ String.fromInt idx

                                    envId : String
                                    envId =
                                        EnvironmentId.toString env.id
                                in
                                li
                                    [ Attr.class "text-gray-900 relative cursor-default select-none py-2 pl-3 pr-9 hover:bg-indigo-100"
                                    , Attr.id attrId
                                    , Attr.attribute "role" "option"
                                    , Events.onClick (SelectedEnvironment env)
                                    ]
                                    [ div [ Attr.class "flex font-normal" ]
                                        [ span
                                            [ Attr.classList
                                                [ ( "font-semibold"
                                                  , case model.selectedEnvironment of
                                                        Just selected ->
                                                            selected.id == env.id

                                                        Nothing ->
                                                            False
                                                  )
                                                , ( "truncate", True )
                                                ]
                                            ]
                                            [ text env.name ]
                                        , span [ Attr.class "text-gray-500 ml-2 truncate" ]
                                            [ text envId ]
                                        ]
                                    , case model.selectedEnvironment of
                                        Just selected ->
                                            Html.Extra.viewIf (selected.id == env.id) <|
                                                span [ Attr.class "pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2 text-indigo-600" ]
                                                    [ Icon.defaults
                                                        |> Icon.withSize 20
                                                        |> Icon.checkmark
                                                    ]

                                        Nothing ->
                                            Html.Extra.nothing
                                    ]
                            )
                            environments
                        )
                    ]
                ]

        RD.Failure _ ->
            div [ Attr.class "w-full" ]
                [ text "Failure :(" ]


viewSelectSpace : Model -> Html Msg
viewSelectSpace model =
    case model.spaces of
        RD.NotAsked ->
            div [ Attr.class "w-full" ]
                [ text "Not Asked" ]

        RD.Loading ->
            div [ Attr.class "w-full" ]
                [ text "Loading..." ]

        RD.Success spaces ->
            div [ Attr.class "w-full" ]
                [ label
                    [ Attr.class "block text-sm font-semibold leading-6 text-gray-900"
                    , Attr.id "listbox-spaces-label"
                    ]
                    [ text "Space" ]
                , div [ Attr.class "relative mt-2" ]
                    [ button
                        [ Attr.class "relative w-full hover:cursor-pointer rounded-md bg-white py-1.5 pl-3 pr-10 text-left text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-500 sm:text-sm sm:leading-6"
                        , Attr.attribute "aria-haspopup" "listbox"
                        , AttrExtra.attributeIf model.showSpaceChoices <|
                            Attr.attribute "aria-expanded" "true"
                        , Attr.attribute "aria-labelledby" "listbox-spaces-label"
                        , Events.onClick ToggleSpaceChoices
                        ]
                        [ span [ Attr.class "inline-flex w-full truncate" ]
                            [ span [ Attr.class "truncate select-none" ]
                                [ case model.selectedSpace of
                                    Just space ->
                                        space.name
                                            |> Maybe.andThen
                                                (\name ->
                                                    if name == "" then
                                                        Just "[Unnamed]"

                                                    else
                                                        Just name
                                                )
                                            |> Maybe.withDefault "[Unnamed]"
                                            |> text

                                    Nothing ->
                                        text "Select..."
                                ]
                            , Html.Extra.viewMaybe
                                (\space ->
                                    span [ Attr.class "ml-2 truncate text-gray-500" ]
                                        [ (.id >> SpaceId.toString >> text) <| space ]
                                )
                                model.selectedSpace
                            ]
                        , span [ Attr.class "pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2 text-gray-400" ]
                            [ Icon.defaults
                                |> Icon.withSize 20
                                |> Icon.selectArrows
                            ]
                        ]
                    , ul
                        [ Attr.class "absolute z-10 mt-1 max-h-60 w-full overflow-auto rounded-md bg-white py-1 text-base shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none sm:text-sm"
                        , Attr.classList [ ( "hidden", not model.showSpaceChoices ) ]
                        , Attr.tabindex -1
                        , Attr.attribute "role" "listbox"
                        , Attr.attribute "aria-labelledby" "listbox-spaces-label"
                        , Attr.attribute "aria-activedescendant" "listbox-option-0"
                        ]
                        (List.indexedMap
                            (\idx space ->
                                let
                                    attrId : String
                                    attrId =
                                        "listbox-option-" ++ String.fromInt idx

                                    spaceId : String
                                    spaceId =
                                        SpaceId.toString space.id
                                in
                                li
                                    [ Attr.class "text-gray-900 relative cursor-default select-none py-2 pl-3 pr-9 hover:bg-indigo-100"
                                    , Attr.id attrId
                                    , Attr.attribute "role" "option"
                                    , Events.onClick (SelectedSpace space)
                                    ]
                                    [ div [ Attr.class "flex font-normal" ]
                                        [ span
                                            [ Attr.classList
                                                [ ( "font-semibold"
                                                  , case model.selectedSpace of
                                                        Just selected ->
                                                            selected.id == space.id

                                                        Nothing ->
                                                            False
                                                  )
                                                , ( "truncate", True )
                                                ]
                                            ]
                                            [ space.name
                                                |> Maybe.andThen
                                                    (\name ->
                                                        if name == "" then
                                                            Just "[Unnamed]"

                                                        else
                                                            Just name
                                                    )
                                                |> Maybe.withDefault "[Unnamed]"
                                                |> text
                                            ]
                                        , span [ Attr.class "text-gray-500 ml-2 truncate" ]
                                            [ text spaceId ]
                                        ]
                                    , case model.selectedSpace of
                                        Just selected ->
                                            Html.Extra.viewIf (selected.id == space.id) <|
                                                span [ Attr.class "pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2 text-indigo-600" ]
                                                    [ Icon.defaults
                                                        |> Icon.withSize 20
                                                        |> Icon.checkmark
                                                    ]

                                        Nothing ->
                                            Html.Extra.nothing
                                    ]
                            )
                            spaces
                        )
                    ]
                ]

        RD.Failure _ ->
            div [ Attr.class "w-full" ] [ text "Failure :(" ]


viewEventsTable : Model -> Html Msg
viewEventsTable model =
    let
        arrowIcon : EventId.EventId -> Html msg
        arrowIcon incomingEventId =
            case model.expandedEventId of
                Just previousEventId ->
                    if incomingEventId == previousEventId then
                        Icon.defaults
                            |> Icon.withSize 20
                            |> Icon.arrowDown

                    else
                        Icon.defaults
                            |> Icon.withSize 20
                            |> Icon.arrowRight

                Nothing ->
                    Icon.defaults
                        |> Icon.withSize 20
                        |> Icon.arrowRight
    in
    if List.length model.events == 0 then
        div [ Attr.class "relative block w-full rounded-lg border-2 border-dashed border-gray-300 p-12 text-center hover:border-gray-400 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2" ]
            [ div [ Attr.class "text-gray-400 flex items-center justify-center mb-4" ]
                [ Icon.defaults
                    |> Icon.withSize 60
                    |> Icon.waitingRoom
                ]
            , span [ Attr.class "mt-2 block text-sm font-semibold text-gray-900" ]
                [ text "Patiently waiting for events." ]
            ]

    else
        div [ Attr.class "" ]
            [ div [ Attr.class "flex items-center" ]
                [ div [ Attr.class "flex-auto" ]
                    [ h1 [ Attr.class "text-base font-semibold leading-6 text-gray-900" ]
                        [ text "Events" ]
                    , p [ Attr.class "mt-2 text-sm text-gray-700" ]
                        [ text "Flatfile's platform was built using the event-driven architecture... Events are streamed in real-time" ]
                    ]
                , div [ Attr.class "mt-4 sm:mt-0 sm:ml-16 sm:flex-none" ]
                    [ button [ Attr.class "block rounded-md bg-indigo-600 py-2 px-3 text-center text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 hidden" ]
                        [ text "Export" ]
                    ]
                ]
            , div [ Attr.class "mt-8 flow-root ring-1 ring-gray-300 rounded-lg overflow-hidden" ]
                [ div [ Attr.class "-my-2 -mx-4 overflow-x-auto sm:-mx-6 lg:-mx-8" ]
                    [ div [ Attr.class "inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8" ]
                        [ table [ Attr.class "min-w-full divide-y divide-gray-300" ]
                            [ thead [ Attr.class "text-left text-sm font-semibold text-gray-900" ]
                                [ tr [ Attr.class "grid grid-cols-5" ]
                                    [ th
                                        [ Attr.class "whitespace-nowrap py-3.5 px-2"
                                        , Attr.scope "col"
                                        ]
                                        []
                                    , th
                                        [ Attr.class "whitespace-nowrap py-3.5 px-2"
                                        , Attr.scope "col"
                                        ]
                                        [ text "Domain" ]
                                    , th
                                        [ Attr.class "whitespace-nowrap py-3.5 px-2"
                                        , Attr.scope "col"
                                        ]
                                        [ text "Timestamp" ]
                                    , th
                                        [ Attr.class "whitespace-nowrap py-3.5 px-2"
                                        , Attr.scope "col"
                                        ]
                                        [ text "Topic" ]
                                    , th
                                        [ Attr.class "whitespace-nowrap py-3.5 px-2"
                                        , Attr.scope "col"
                                        ]
                                        [ text "Unique Identifier" ]
                                    , th [ Attr.class "hidden" ] []
                                    ]
                                ]
                            , tbody [ Attr.class "divide-y divide-gray-200 bg-white" ]
                                (List.map
                                    (\event ->
                                        tr
                                            [ Attr.class "grid grid-cols-5 flex items-center"
                                            , Attr.classList
                                                [ ( "bg-cyan-50"
                                                  , model.expandedEventId
                                                        |> Maybe.map (\id -> id == event.id)
                                                        |> Maybe.withDefault False
                                                  )
                                                ]
                                            ]
                                            [ td
                                                [ Attr.class "whitespace-nowrap p-2 text-sm text-gray-500 cursor-pointer"
                                                , Events.onClick (ClickedEvent event.id)
                                                ]
                                                [ arrowIcon event.id ]
                                            , td
                                                [ Attr.class "whitespace-nowrap p-2 text-sm text-gray-500" ]
                                                [ EventDomain.toHtml event.domain ]
                                            , td
                                                [ Attr.class "whitespace-nowrap p-2 text-sm text-gray-500" ]
                                                [ event.createdAt
                                                    |> Maybe.map (Timestamp.toString model.timeZone)
                                                    |> Maybe.withDefault "Unknown DateTime"
                                                    |> text
                                                ]
                                            , td
                                                [ Attr.class "whitespace-nowrap p-2 text-sm text-gray-500" ]
                                                [ EventTopic.toHtml event.topic ]
                                            , td
                                                [ Attr.class "whitespace-nowrap p-2 text-sm text-gray-500" ]
                                                [ span [ Attr.class "" ]
                                                    [ text <| EventId.toString event.id ]
                                                ]
                                            , td
                                                [ Attr.class "col-span-full px-10 py-2 border-t cursor-default bg-white"
                                                , Attr.classList
                                                    [ ( "hidden"
                                                      , model.expandedEventId
                                                            |> Maybe.map (\id -> id /= event.id)
                                                            |> Maybe.withDefault True
                                                      )
                                                    ]
                                                ]
                                                [ div [ Attr.class "mb-1.5 text-gray-500 select-none" ]
                                                    [ span [] [ text "Context" ]
                                                    ]
                                                , div [ Attr.class "grid grid-cols-2 gap-x-4 gap-y-1 w-60" ]
                                                    [ span [ Attr.class "text-sm font-semibold text-gray-800 select-none" ]
                                                        [ text "@environment_id:" ]
                                                    , span [ Attr.class "text-sm text-gray-500 cursor-text" ]
                                                        [ text <| EnvironmentId.toString event.context.environmentId ]
                                                    , span [ Attr.class "text-sm font-semibold text-gray-800 select-none" ]
                                                        [ text "@account_id:" ]
                                                    , span [ Attr.class "text-sm text-gray-500 cursor-text" ]
                                                        [ text event.context.accountId ]
                                                    , Html.Extra.viewMaybe
                                                        (\_ ->
                                                            span [ Attr.class "text-sm font-semibold text-gray-800 select-none" ]
                                                                [ text "@action_name:" ]
                                                        )
                                                        event.context.actionName
                                                    , Html.Extra.viewMaybe
                                                        (\actionName ->
                                                            span [ Attr.class "text-sm text-gray-500 cursor-text" ]
                                                                [ text actionName ]
                                                        )
                                                        event.context.actionName
                                                    , Html.Extra.viewMaybe
                                                        (\_ ->
                                                            span [ Attr.class "text-sm font-semibold text-gray-800 select-none" ]
                                                                [ text "@space_id:" ]
                                                        )
                                                        event.context.spaceId
                                                    , Html.Extra.viewMaybe
                                                        (\spaceId ->
                                                            span [ Attr.class "text-sm text-gray-500 cursor-text" ]
                                                                [ text <| SpaceId.toString spaceId ]
                                                        )
                                                        event.context.spaceId
                                                    , Html.Extra.viewMaybe
                                                        (\_ ->
                                                            span [ Attr.class "text-sm font-semibold text-gray-800 select-none" ]
                                                                [ text "@workbook_id:" ]
                                                        )
                                                        event.context.workbookId
                                                    , Html.Extra.viewMaybe
                                                        (\workbookId ->
                                                            span [ Attr.class "text-sm text-gray-500 cursor-text" ]
                                                                [ text workbookId ]
                                                        )
                                                        event.context.workbookId
                                                    , Html.Extra.viewMaybe
                                                        (\_ ->
                                                            span [ Attr.class "text-sm font-semibold text-gray-800 select-none" ]
                                                                [ text "@sheet_id:" ]
                                                        )
                                                        event.context.sheetId
                                                    , Html.Extra.viewMaybe
                                                        (\sheetId ->
                                                            span [ Attr.class "text-sm text-gray-500 cursor-text" ]
                                                                [ text sheetId ]
                                                        )
                                                        event.context.sheetId
                                                    , Html.Extra.viewMaybe
                                                        (\_ ->
                                                            span [ Attr.class "text-sm font-semibold text-gray-800 select-none" ]
                                                                [ text "@job_id:" ]
                                                        )
                                                        event.context.jobId
                                                    , Html.Extra.viewMaybe
                                                        (\jobId ->
                                                            span [ Attr.class "text-sm text-gray-500 cursor-text" ]
                                                                [ text jobId ]
                                                        )
                                                        event.context.jobId
                                                    , Html.Extra.viewMaybe
                                                        (\_ ->
                                                            span [ Attr.class "text-sm font-semibold text-gray-800 select-none" ]
                                                                [ text "@file_id:" ]
                                                        )
                                                        event.context.fileId
                                                    , Html.Extra.viewMaybe
                                                        (\fileId ->
                                                            span [ Attr.class "text-sm text-gray-500 cursor-text" ]
                                                                [ text fileId ]
                                                        )
                                                        event.context.fileId
                                                    , Html.Extra.viewMaybe
                                                        (\_ ->
                                                            span [ Attr.class "text-sm font-semibold text-gray-800 select-none" ]
                                                                [ text "@proceeding_event_id:" ]
                                                        )
                                                        event.context.proceedingEventId
                                                    , Html.Extra.viewMaybe
                                                        (\eventId ->
                                                            span [ Attr.class "text-sm text-gray-500 cursor-text" ]
                                                                [ text eventId ]
                                                        )
                                                        event.context.proceedingEventId
                                                    , Html.Extra.viewMaybe
                                                        (\_ ->
                                                            span [ Attr.class "text-sm font-semibold text-gray-800 select-none" ]
                                                                [ text "@actor_id:" ]
                                                        )
                                                        event.context.actorId
                                                    , Html.Extra.viewMaybe
                                                        (\actorId ->
                                                            span [ Attr.class "text-sm text-gray-500 cursor-text" ]
                                                                [ text actorId ]
                                                        )
                                                        event.context.actorId
                                                    ]
                                                , div [ Attr.class "mt-4 mb-1.5 text-gray-500 select-none" ]
                                                    [ span [] [ text "Payload" ]
                                                    ]
                                                , pre []
                                                    [ code [ Attr.class "font-mono text-sm text-gray-800" ]
                                                        [ text <| E.encode 2 event.payload ]
                                                    ]
                                                ]
                                            ]
                                    )
                                    model.events
                                )
                            ]
                        ]
                    ]
                ]
            ]


viewAgentsTable : Model -> Html msg
viewAgentsTable model =
    case model.agents of
        RD.NotAsked ->
            div [ Attr.class "" ]
                [ text "Not Asked" ]

        RD.Loading ->
            div [ Attr.class "" ]
                [ text "Loading..." ]

        RD.Success agents ->
            if List.length agents == 0 then
                div [ Attr.class "" ]
                    [ text "No Agents" ]

            else
                div [ Attr.class "w-1/2 mb-8" ]
                    [ div [ Attr.class "flex items-center" ]
                        [ div [ Attr.class "flex-auto" ]
                            [ h1 [ Attr.class "text-base font-semibold leading-6 text-gray-900" ]
                                [ text "Agents" ]
                            , p [ Attr.class "mt-2 text-sm text-gray-700" ]
                                [ text "Agents are workers that subscribe to certain event topics..." ]
                            ]
                        ]
                    , div [ Attr.class "mt-8 flow-root ring-1 ring-gray-300 rounded-lg overflow-hidden" ]
                        [ div [ Attr.class "-my-2 -mx-4 overflow-x-auto sm:-mx-6 lg:-mx-8" ]
                            [ div [ Attr.class "inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8" ]
                                [ table [ Attr.class "min-w-full divide-y divide-gray-300" ]
                                    [ thead [ Attr.class "text-left text-sm font-semibold text-gray-900" ]
                                        [ tr [ Attr.class "flex items-center" ]
                                            [ th
                                                [ Attr.class "whitespace-nowrap py-3.5 px-2"
                                                , Attr.scope "col"
                                                ]
                                                [ text "Unique Identifier" ]
                                            , th
                                                [ Attr.class "whitespace-nowrap py-3.5 px-2"
                                                , Attr.scope "col"
                                                ]
                                                [ text "Subscribed To" ]
                                            ]
                                        ]
                                    , tbody [ Attr.class "divide-y divide-gray-200 bg-white" ]
                                        (List.map
                                            (\agent ->
                                                tr [ Attr.class "flex items-center" ]
                                                    [ td [ Attr.class "whitespace-nowrap p-2 text-sm text-gray-500" ]
                                                        [ text <| AgentId.toString agent.id ]
                                                    , td [ Attr.class "whitespace-nowrap p-2 space-x-2" ]
                                                        (case agent.topics of
                                                            Just topics ->
                                                                List.map EventTopic.toHtml topics

                                                            Nothing ->
                                                                [ Html.Extra.nothing ]
                                                        )
                                                    ]
                                            )
                                            agents
                                        )
                                    ]
                                ]
                            ]
                        ]
                    ]

        RD.Failure _ ->
            div [ Attr.class "" ]
                [ text "Failure" ]


view : Model -> Browser.Document Msg
view model =
    { title = "Crispy Critters"
    , body =
        [ div [ Attr.class "w-4/5 m-auto mt-20" ]
            [ case model.accessToken of
                RD.NotAsked ->
                    section [ mkTestAttribute "section-auth", Attr.class "" ]
                        [ div [ Attr.class "w-full" ]
                            [ viewAuthForm model ]
                        ]

                RD.Loading ->
                    section [ mkTestAttribute "section-auth", Attr.class "" ]
                        [ div [ Attr.class "w-full" ]
                            [ text "Loading..." ]
                        ]

                RD.Success _ ->
                    section [ mkTestAttribute "section-selections", Attr.class "" ]
                        [ div [ Attr.class "flex space-x-20" ]
                            [ viewSelectEnvironment model
                            , viewSelectSpace model
                            ]
                        ]

                RD.Failure _ ->
                    section [ mkTestAttribute "section-auth", Attr.class "" ]
                        [ div []
                            [ text "Uh oh... Failed to authenticate :(" ]
                        ]
            , case model.selectedEnvironment of
                Just env ->
                    case model.selectedSpace of
                        Just space ->
                            section [ mkTestAttribute "section-data", Attr.class "" ]
                                [ viewMeta env space model.timeZone
                                , viewAgentsTable model
                                , viewEventsTable model
                                ]

                        Nothing ->
                            section [ mkTestAttribute "section-data", Attr.class "" ] []

                Nothing ->
                    section [ mkTestAttribute "section-data", Attr.class "" ] []
            ]
        ]
    }



-- MAIN


main : Program D.Value Model Msg
main =
    Browser.document
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
