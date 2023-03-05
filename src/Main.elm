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
import Svg exposing (circle, g, path, svg)
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
    , expandedEventId : Maybe String
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
    , expandedEventId = Nothing
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
viewEventsTable model =
    let
        arrowIcon : Html msg
        arrowIcon =
            case model.expandedEventId of
                Just eventId ->
                    td [ Attr.class "whitespace-nowrap py-2 text-sm text-gray-500" ]
                        [ svg
                            [ SvgAttr.class "h-5 w-5"
                            , SvgAttr.version "1.1"
                            , SvgAttr.viewBox "0 0 24 24"
                            , SvgAttr.fill "currentColor"
                            ]
                            [ path [ SvgAttr.d "M15.1997 10.4919L13.2297 8.52188L10.0197 5.31188C9.33969 4.64188 8.17969 5.12188 8.17969 6.08188V12.3119V17.9219C8.17969 18.8819 9.33969 19.3619 10.0197 18.6819L15.1997 13.5019C16.0297 12.6819 16.0297 11.3219 15.1997 10.4919Z" ] []
                            ]
                        ]

                Nothing ->
                    td [] []

        domainIcon : String -> Html msg
        domainIcon domain =
            let
                icon : Html msg
                icon =
                    case domain of
                        "workbook" ->
                            svg
                                [ SvgAttr.class "h-6 w-6"
                                , SvgAttr.version "1.1"
                                , SvgAttr.viewBox "0 0 512 512"
                                , SvgAttr.fill "none"
                                ]
                                [ circle
                                    [ SvgAttr.cx "256"
                                    , SvgAttr.cy "256"
                                    , SvgAttr.r "256"
                                    , SvgAttr.fill "#F06C9B"
                                    ]
                                    []
                                , path
                                    [ SvgAttr.stroke "white"
                                    , SvgAttr.strokeWidth "3"
                                    , SvgAttr.strokeLinecap "round"
                                    , SvgAttr.d "M82.8904 104.169C90.8559 104.169 122.257 98.9941 128.039 104.766C132.621 109.34 128.892 133.971 129.983 140.285C133.4 160.068 138.957 177.725 148.671 195.354C156.43 209.438 160.431 224.998 168.405 239.082C177.561 255.253 186.097 274.395 193.222 291.614C198.342 303.988 206.128 316.732 209.368 329.67C210.399 333.789 215.494 348.681 218.786 351.31C225.567 356.725 225.514 386.655 225.514 356.533C225.514 337.995 231.948 321.715 238.371 305.045C244.002 290.43 248.903 274.897 256.46 261.318C259.456 255.936 258.72 249.191 261.095 243.857C264.56 236.075 272.325 263.334 274.55 268.631C288.912 302.818 304.559 334.742 321.792 367.428C328.564 380.272 329.419 363.239 331.809 353.698C339.369 323.51 349.82 292.903 351.842 261.617C353.616 234.164 353.793 207.042 359.466 179.983C363.978 158.466 371.284 137.717 376.061 116.257C376.974 112.154 378.696 104.959 378.901 101.483C379.085 98.3735 378.901 95.1961 378.901 92.0807C378.901 90.6211 376.289 86.4801 376.808 85.9619C383.115 79.6658 419.448 85.3649 428.087 85.3649C443.102 85.3649 432.607 91.3424 430.03 101.632C425.829 118.409 424.063 135.771 418.668 151.926C411.746 172.657 403.709 197.809 400.579 219.68C394.899 259.371 391.31 298.975 380.994 337.878C376.332 355.459 363.924 372.252 359.915 390.261C358.216 397.894 351.415 421.154 343.918 421.154C327 421.154 297.695 427.82 288.005 410.409C283.992 403.199 279.569 398.443 276.643 390.411C275.139 386.283 273.13 375.368 269.915 372.8C265.568 369.329 254.843 400.674 251.826 404.439C247.562 409.76 242.013 414.368 237.773 419.811C229.416 430.537 229.264 428.818 215.796 425.333C199.688 421.164 179.767 426.141 179.767 405.036C179.767 391.191 176.753 373.326 172.292 359.966C167.164 344.61 160.803 331.763 152.857 317.88C147.055 307.745 136.429 300.333 130.731 289.525C120.633 270.373 103.647 253.151 98.8869 231.769C95.5191 216.64 90.5093 200.484 86.1794 185.355C82.3163 171.858 67.4031 114.586 82.8904 106.855"
                                    ]
                                    []
                                ]

                        "file" ->
                            svg
                                [ SvgAttr.class "h-6 w-6"
                                , SvgAttr.version "1.1"
                                , SvgAttr.viewBox "0 0 512 512"
                                , SvgAttr.fill "none"
                                ]
                                [ circle
                                    [ SvgAttr.cx "256"
                                    , SvgAttr.cy "256"
                                    , SvgAttr.r "256"
                                    , SvgAttr.fill "#7B287D"
                                    ]
                                    []
                                , path
                                    [ SvgAttr.stroke "white"
                                    , SvgAttr.strokeWidth "3"
                                    , SvgAttr.strokeLinecap "round"
                                    , SvgAttr.d "M171.864 427.367C171.864 417.635 168.621 408.086 168.621 398.163C168.621 378.171 167 358.267 167 338.132C167 273.467 170.242 208.831 170.242 144.25C170.242 132.757 173.421 120.906 171.773 109.367C170.597 101.123 166.208 90.3348 177.988 89.8982C207.118 88.8185 235.108 85.0308 264.361 85.0308C299.352 85.0308 334.525 83.4084 369.648 83.4084C374.556 83.4084 381.17 81.1207 380.997 87.3744C380.836 93.1508 379.375 98.6736 379.375 104.5C379.375 110.297 381.477 124.875 373.611 127.124C359.653 131.115 344.158 126.818 330.019 129.648C314.686 132.717 296.66 127.849 281.744 132.442C262.749 138.291 238.64 130.395 220.499 139.473C202.651 148.404 207.53 179.928 207.53 196.168C207.53 205.503 208.62 212.344 219.058 213.294C238.283 215.043 257.932 216.449 277.241 216.449C285.525 216.449 292.789 215.546 299.937 219.333C306.591 222.858 306.422 240.774 306.422 247.365C306.422 255.596 310.058 269.989 298.136 269.989C280.356 269.989 262.506 266.745 244.817 266.745C235.14 266.745 229.139 273.091 222.12 279.724C216.999 284.565 214.135 287.981 211.132 294.326C209.452 297.877 211.425 302.687 209.961 306.494C206.678 315.039 209.151 328.155 209.151 337.411C209.151 349.549 209.151 361.688 209.151 373.826C209.151 387.277 213.627 412.22 205.008 423.31C199.782 430.035 173.485 434.519 173.485 422.499"
                                    ]
                                    []
                                ]

                        "job" ->
                            svg
                                [ SvgAttr.class "h-6 w-6"
                                , SvgAttr.version "1.1"
                                , SvgAttr.viewBox "0 0 512 512"
                                , SvgAttr.fill "none"
                                ]
                                [ circle
                                    [ SvgAttr.cx "256"
                                    , SvgAttr.cy "256"
                                    , SvgAttr.r "256"
                                    , SvgAttr.fill "#7067CF"
                                    ]
                                    []
                                , path
                                    [ SvgAttr.stroke "white"
                                    , SvgAttr.strokeWidth "3"
                                    , SvgAttr.strokeLinecap "round"
                                    , SvgAttr.d "M138.148 120.282C138.613 124.463 149.177 165.917 150.528 166.303C163.69 170.062 183.667 166.454 197.328 166.454C207.72 166.454 260.433 161.559 260.433 171.886C260.433 197.366 265.868 222.689 265.868 248.537C265.868 274.344 277.751 314.453 263.151 338.165C245.555 366.743 212.644 381.017 178.91 381.017C164.318 381.017 151.545 377.115 139.356 370.153C135.722 368.078 131.367 356.23 128.486 355.819C126.131 355.483 122.583 370.184 121.24 372.869C117.55 380.246 110.488 388.829 108.408 396.106C103.533 413.159 143.749 414.778 156.567 418.438C167.49 421.557 182.698 419.041 193.856 419.041C210.613 419.041 227.371 419.041 244.129 419.041C326.041 419.041 317.499 303.685 317.499 247.934C317.499 229.827 317.499 211.721 317.499 193.614C317.499 182.132 312.33 163.738 326.407 163.738C351.361 163.738 376.793 165.205 401.74 163.738C406.803 163.44 404.458 139.468 404.458 135.22C404.458 124.207 401.74 112.815 401.74 101.27C401.74 84.7476 384.649 93.1223 373.207 93.1223C334.572 93.1223 296.014 92.2076 257.716 95.6874C230.12 98.1948 199.437 98.5543 171.965 98.5543C166.008 98.5543 146.204 95.3725 141.47 99.1578C137.106 102.647 135.431 101.429 135.431 108.06C135.431 111.312 135.431 120.729 135.431 112.134"
                                    ]
                                    []
                                ]

                        "space" ->
                            svg
                                [ SvgAttr.class "h-6 w-6"
                                , SvgAttr.version "1.1"
                                , SvgAttr.viewBox "0 0 512 512"
                                , SvgAttr.fill "none"
                                ]
                                [ circle
                                    [ SvgAttr.cx "256"
                                    , SvgAttr.cy "256"
                                    , SvgAttr.r "256"
                                    , SvgAttr.fill "#CBF3D2"
                                    ]
                                    []
                                , path
                                    [ SvgAttr.stroke "black"
                                    , SvgAttr.strokeWidth "3"
                                    , SvgAttr.strokeLinecap "round"
                                    , SvgAttr.d "M316.484 59.3565C291.68 59.3565 266.15 57.6809 241.587 61.1894C208.439 65.9242 179.291 79.0057 153.989 101.774C135.273 118.617 121.206 140.399 129.373 166.71C141.544 205.922 182.682 245.546 221.684 257.307C251.863 266.407 282.87 266.988 312.948 273.672C332.845 278.092 340.052 291.882 340.052 311.507C340.052 353.187 313.568 372.778 271.703 372.778C244.192 372.778 216.474 373.319 189.212 370.29C179.537 369.215 167.503 367.905 160.405 361.518C156.292 357.817 148.949 358.865 144.954 355.758C144.293 355.243 139.23 365.373 137.884 368.064C133.657 376.517 129.473 392.658 132.908 402.103C135.07 408.048 150.964 408.578 155.56 409.435C171.424 412.392 187.097 416.36 203.091 418.599C214.578 420.207 226.097 419.908 237.659 419.908C249.018 419.908 260.451 420.488 271.703 418.73C284.856 416.675 298.52 419.489 311.246 415.719C324.8 411.704 338.319 413.985 349.48 403.413C364.208 389.461 373.64 380.348 381.167 360.995C386.658 346.878 382.476 324.096 382.476 309.151C382.476 294.269 381.558 282.44 374.882 269.089C363.183 245.694 328.095 236.583 304.699 231.385C278.842 225.639 249.661 217.63 227.446 203.106C212.085 193.064 188.93 178.864 184.629 159.51C178.856 133.538 192.455 112.402 217.494 105.964C236.416 101.099 253.644 101.774 273.536 101.774C283.784 101.774 307.85 106.047 317.662 100.596C324.596 96.7443 328.268 102.383 328.268 92.3482C328.268 87.0377 330.625 82.5941 330.625 77.0307C330.625 67.7009 323.351 61.5775 316.484 57"
                                    ]
                                    []
                                ]

                        _ ->
                            svg [] []
            in
            td [ Attr.class "whitespace-nowrap py-2 px-2 text-sm text-gray-500" ] [ icon ]

        badge : String -> Html msg
        badge eventTopic =
            span [ Attr.class "inline-flex items-center rounded-md bg-gray-100 px-2.5 py-0.5 text-sm font-medium text-gray-800" ] [ text eventTopic ]
    in
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
                                [ th [ Attr.class "whitespace-nowrap py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-0", Attr.scope "col" ] []
                                , th [ Attr.class "whitespace-nowrap py-3.5 px-2 text-left text-sm font-semibold text-gray-900", Attr.scope "col" ] [ text "Domain" ]
                                , th [ Attr.class "whitespace-nowrap py-3.5 px-2 text-left text-sm font-semibold text-gray-900", Attr.scope "col" ] [ text "Timestamp" ]
                                , th [ Attr.class "whitespace-nowrap py-3.5 px-2 text-left text-sm font-semibold text-gray-900", Attr.scope "col" ] [ text "Summary" ]
                                ]
                            ]
                        , tbody [ Attr.class "divide-y divide-gray-200 bg-white" ]
                            [ tr [ Attr.class "" ]
                                [ arrowIcon
                                , domainIcon "workbook"
                                , td [ Attr.class "whitespace-nowrap py-2 px-2 text-sm text-gray-500" ] [ text "2019-12-17 10:10:37.951 MST" ]
                                , td [ Attr.class "whitespace-nowrap py-2 px-2 text-sm text-gray-500" ]
                                    [ badge "records:created"
                                    , text "Sum helpful summary text"
                                    ]
                                ]
                            , tr [ Attr.class "" ]
                                [ arrowIcon
                                , domainIcon "file"
                                , td [ Attr.class "whitespace-nowrap py-2 px-2 text-sm text-gray-500" ] [ text "2019-12-17 10:10:37.951 MST" ]
                                , td [ Attr.class "whitespace-nowrap py-2 px-2 text-sm text-gray-500" ]
                                    [ badge "file:uploaded"
                                    , text "Sum helpful summary text"
                                    ]
                                ]
                            , tr [ Attr.class "" ]
                                [ arrowIcon
                                , domainIcon "job"
                                , td [ Attr.class "whitespace-nowrap py-2 px-2 text-sm text-gray-500" ] [ text "2019-12-17 10:10:37.951 MST" ]
                                , td [ Attr.class "whitespace-nowrap py-2 px-2 text-sm text-gray-500" ]
                                    [ badge "job:failed"
                                    , text "Sum helpful summary text"
                                    ]
                                ]
                            , tr [ Attr.class "" ]
                                [ arrowIcon
                                , domainIcon "space"
                                , td [ Attr.class "whitespace-nowrap py-2 px-2 text-sm text-gray-500" ] [ text "2019-12-17 10:10:37.951 MST" ]
                                , td [ Attr.class "whitespace-nowrap py-2 px-2 text-sm text-gray-500" ]
                                    [ badge "space:created"
                                    , text "Sum helpful summary text"
                                    ]
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
