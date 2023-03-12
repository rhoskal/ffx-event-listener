module Main exposing (..)

import Api exposing (Cred)
import Browser
import Environment exposing (Environment)
import EnvironmentId
import Html exposing (..)
import Html.Attributes as Attr
import Html.Attributes.Extra as AttrExtra
import Html.Events as Events
import Html.Extra
import Icon
import InteropDefinitions
import InteropPorts
import Json.Decode as Decode
import Json.Encode as Encode
import PubNub exposing (Event, EventDomain(..), SubscriptionCreds)
import RemoteData as RD exposing (RemoteData(..), WebData)
import Space exposing (Space)
import SpaceId
import Task
import Time
import Utils exposing (mkTestAttribute, posixToString)



-- MODEL


type alias Model =
    { clientId : String
    , secretKey : String
    , accessToken : WebData Cred
    , showSecret : Bool
    , showEnvironmentChoices : Bool
    , selectedEnvironment : Maybe Environment
    , environments : WebData (List Environment)
    , showSpaceChoices : Bool
    , selectedSpace : Maybe Space
    , spaces : WebData (List Space)
    , events : List Event
    , subscriptionCreds : WebData SubscriptionCreds
    , expandedEventId : Maybe String
    , timeZone : Time.Zone
    }


initialModel : Model
initialModel =
    { clientId = ""
    , secretKey = ""
    , accessToken = NotAsked
    , showSecret = False
    , showEnvironmentChoices = False
    , selectedEnvironment = Nothing
    , environments = NotAsked
    , showSpaceChoices = False
    , selectedSpace = Nothing
    , spaces = NotAsked
    , events = []
    , subscriptionCreds = NotAsked
    , expandedEventId = Nothing
    , timeZone = Time.utc
    }


init : Decode.Value -> ( Model, Cmd Msg )
init flags =
    case InteropPorts.decodeFlags flags of
        Err _ ->
            ( initialModel, Task.attempt TimeZone Time.here )

        Ok _ ->
            ( initialModel, Task.attempt TimeZone Time.here )



-- UPDATE


type Msg
    = Reset
    | OpenExternalLink String
    | ClickedEvent String
    | ReceivedDomainEvent (Result Decode.Error InteropDefinitions.ToElm)
    | TimeZone (Result () Time.Zone)
      -- Form
    | EnteredClientId String
    | EnteredSecretKey String
    | ToggleShowSecret
    | SelectedEnvironment Environment
    | ToggleEnvironmentChoices
    | SelectedSpace Space
    | ToggleSpaceChoices
      -- Http
    | SendAuthRequest
    | GotAuthResponse (WebData Cred)
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
                    , Decode.errorToString error
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
            ( { model
                | selectedEnvironment = Just env
                , showEnvironmentChoices = False
              }
            , Space.list env.id (RD.toMaybe model.accessToken) GotSpacesResponse
            )

        ToggleEnvironmentChoices ->
            ( { model | showEnvironmentChoices = not model.showEnvironmentChoices }, Cmd.none )

        SelectedSpace space ->
            ( { model
                | selectedSpace = Just space
                , showSpaceChoices = False
              }
            , PubNub.auth space.id (RD.toMaybe model.accessToken) GotSubscriptionCredsResponse
            )

        ToggleSpaceChoices ->
            ( { model | showSpaceChoices = not model.showSpaceChoices }, Cmd.none )

        GotAuthResponse response ->
            case response of
                Success _ ->
                    ( { model | accessToken = response }
                    , Environment.list (RD.toMaybe response) GotEnvironmentsResponse
                    )

                Failure _ ->
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
            ( model, Api.login clientId secretKey GotAuthResponse )

        GotEnvironmentsResponse response ->
            ( { model | environments = response }, Cmd.none )

        GotSpacesResponse response ->
            ( { model | spaces = response }, Cmd.none )

        GotSubscriptionCredsResponse response ->
            ( { model | subscriptionCreds = response }
            , case response of
                Success data ->
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


viewMeta : Environment -> Space -> Time.Zone -> Html Msg
viewMeta selectedEnvironment selectedSpace timeZone =
    let
        spaceName : String
        spaceName =
            Maybe.withDefault ("[Unnamed — " ++ SpaceId.toString selectedSpace.id ++ "]") selectedSpace.name

        environmentName : String
        environmentName =
            selectedEnvironment.name

        createdAt : String
        createdAt =
            selectedSpace.createdAt
                |> Maybe.map (\posix -> posixToString posix timeZone)
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
        NotAsked ->
            div [ Attr.class "w-full" ]
                [ text "Not Asked" ]

        Loading ->
            div [ Attr.class "w-full" ]
                [ text "Loading..." ]

        Success environments ->
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
                                [ text <|
                                    Maybe.withDefault "Select..." <|
                                        Maybe.map (\env -> env.name) model.selectedEnvironment
                                ]
                            , span [ Attr.class "ml-2 truncate text-gray-500" ]
                                [ text <|
                                    Maybe.withDefault "" <|
                                        Maybe.map (\env -> EnvironmentId.toString env.id) model.selectedEnvironment
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

        Failure _ ->
            div [ Attr.class "w-full" ]
                [ text "Failure :(" ]


viewSelectSpace : Model -> Html Msg
viewSelectSpace model =
    case model.spaces of
        NotAsked ->
            div [ Attr.class "w-full" ]
                [ text "Not Asked" ]

        Loading ->
            div [ Attr.class "w-full" ]
                [ text "Loading..." ]

        Success spaces ->
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
                                [ text <|
                                    Maybe.withDefault "Select..." <|
                                        Maybe.andThen (\name -> name) <|
                                            Maybe.map (\space -> space.name) model.selectedSpace
                                ]
                            , span [ Attr.class "ml-2 truncate text-gray-500" ]
                                [ text <|
                                    Maybe.withDefault "" <|
                                        Maybe.map (\space -> SpaceId.toString space.id) model.selectedSpace
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
                                            [ text <| Maybe.withDefault "[Unnamed]" space.name ]
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

        Failure _ ->
            div [ Attr.class "w-full" ] [ text "Failure :(" ]


viewEventsTable : Model -> Html Msg
viewEventsTable model =
    let
        arrowIcon : String -> Html msg
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

        domainBadge : EventDomain -> Html msg
        domainBadge domain =
            case domain of
                FileDomain ->
                    span [ Attr.class "inline-flex items-center rounded-md bg-sky-200 px-2.5 py-0.5 text-sm font-medium text-sky-500 select-none" ]
                        [ text (PubNub.domainToString domain) ]

                JobDomain ->
                    span [ Attr.class "inline-flex items-center rounded-md bg-purple-200 px-2.5 py-0.5 text-sm font-medium text-purple-500 select-none" ]
                        [ text (PubNub.domainToString domain) ]

                SpaceDomain ->
                    span [ Attr.class "inline-flex items-center rounded-md bg-green-200 px-2.5 py-0.5 text-sm font-medium text-green-500 select-none" ]
                        [ text (PubNub.domainToString domain) ]

                WorkbookDomain ->
                    span [ Attr.class "inline-flex items-center rounded-md bg-fuchsia-200 px-2.5 py-0.5 text-sm font-medium text-fuchsia-500 select-none" ]
                        [ text (PubNub.domainToString domain) ]

        badge : String -> Html msg
        badge eventTopic =
            span [ Attr.class "inline-flex items-center rounded-md bg-gray-100 px-2.5 py-0.5 text-sm font-medium text-gray-800 select-none" ]
                [ text eventTopic ]
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
            , div [ Attr.class "mt-8 flow-root ring-1 ring-gray-300 rounded-lg" ]
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
                                        [ text "Summary" ]
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
                                                [ ( "bg-cyan-50", Maybe.withDefault "non_existent_id" model.expandedEventId == event.id )
                                                ]
                                            ]
                                            [ td
                                                [ Attr.class "whitespace-nowrap p-2 text-sm text-gray-500 cursor-pointer"
                                                , Events.onClick (ClickedEvent event.id)
                                                ]
                                                [ arrowIcon event.id
                                                ]
                                            , td
                                                [ Attr.class "whitespace-nowrap p-2 text-sm text-gray-500" ]
                                                [ domainBadge event.domain ]
                                            , td
                                                [ Attr.class "whitespace-nowrap p-2 text-sm text-gray-500" ]
                                                [ text <|
                                                    (event.createdAt
                                                        |> Maybe.map (\posix -> posixToString posix model.timeZone)
                                                        |> Maybe.withDefault "Unknown DateTime"
                                                    )
                                                ]
                                            , td
                                                [ Attr.class "whitespace-nowrap p-2 text-sm text-gray-500" ]
                                                [ badge (PubNub.topicToString event.topic)
                                                , span [ Attr.class "ml-2" ]
                                                    [ text "" ]
                                                ]
                                            , td
                                                [ Attr.class "whitespace-nowrap p-2 text-sm text-gray-500" ]
                                                [ span [ Attr.class "" ]
                                                    [ text event.id ]
                                                ]
                                            , td
                                                [ Attr.class "col-span-full px-10 py-2 border-t cursor-default bg-white"
                                                , Attr.classList
                                                    [ ( "hidden"
                                                      , Maybe.withDefault "non_existent_id" model.expandedEventId /= event.id
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
                                                    ]
                                                , div [ Attr.class "mt-4 mb-1.5 text-gray-500 select-none" ]
                                                    [ span [] [ text "Payload" ]
                                                    ]
                                                , pre []
                                                    [ code [ Attr.class "font-mono text-sm text-gray-800" ] [ text <| Encode.encode 2 event.payload ]
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


view : Model -> Browser.Document Msg
view model =
    { title = "Crispy Critters"
    , body =
        [ div [ Attr.class "w-4/5 m-auto mt-20" ]
            [ case model.accessToken of
                NotAsked ->
                    section [ mkTestAttribute "section-auth", Attr.class "" ]
                        [ div [ Attr.class "w-full" ]
                            [ viewAuthForm model
                            ]
                        ]

                Loading ->
                    section [ mkTestAttribute "section-auth", Attr.class "" ]
                        [ div [ Attr.class "w-full" ]
                            [ text "Loading..." ]
                        ]

                Success _ ->
                    section [ mkTestAttribute "section-selections", Attr.class "" ]
                        [ div [ Attr.class "flex space-x-20" ]
                            [ viewSelectEnvironment model
                            , viewSelectSpace model
                            ]
                        ]

                Failure _ ->
                    section [ mkTestAttribute "section-auth", Attr.class "" ]
                        [ div []
                            [ text "Failure :(" ]
                        ]
            , case model.selectedEnvironment of
                Just env ->
                    case model.selectedSpace of
                        Just space ->
                            section [ mkTestAttribute "section-events", Attr.class "" ]
                                [ viewMeta env space model.timeZone
                                , viewEventsTable model
                                ]

                        Nothing ->
                            section [ mkTestAttribute "section-events", Attr.class "" ] []

                Nothing ->
                    section [ mkTestAttribute "section-events", Attr.class "" ] []
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
