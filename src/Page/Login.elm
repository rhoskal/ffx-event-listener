module Page.Login exposing
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
import Html.Events as Events
import Html.Extra
import Icon
import Session



-- MODEL


type alias Model =
    { showPassword : Bool
    , form : Form
    , parsedEmail : Maybe Email
    , parsedPassword : Maybe Password
    , session : Session.Session
    }


init : Session.Session -> ( Model, Cmd Msg )
init session_ =
    ( { showPassword = False
      , form =
            { email = ""
            , password = ""
            , rememberMe = False
            }
      , parsedEmail = Nothing
      , parsedPassword = Nothing
      , session = session_
      }
    , Cmd.none
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- UPDATE


type Msg
    = SubmitForm
    | EmailChanged String
    | PasswordChanged String
    | ToggleRememberMe
    | ToggleShowPassword
    | ValidateEmail
    | ValidatePassword


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubmitForm ->
            ( model, Cmd.none )

        EmailChanged email ->
            let
                setEmail : String -> Form -> Form
                setEmail val form =
                    { form | email = val }
            in
            ( { model
                | form = model.form |> setEmail email
              }
            , Cmd.none
            )

        PasswordChanged password ->
            let
                setPassword : String -> Form -> Form
                setPassword val form =
                    { form | password = val }
            in
            ( { model
                | form = model.form |> setPassword password
              }
            , Cmd.none
            )

        ToggleRememberMe ->
            let
                setRememberMe : Bool -> Form -> Form
                setRememberMe val form =
                    { form | rememberMe = val }
            in
            ( { model
                | form = model.form |> setRememberMe (not model.form.rememberMe)
              }
            , Cmd.none
            )

        ToggleShowPassword ->
            ( { model
                | showPassword = not model.showPassword
              }
            , Cmd.none
            )

        ValidateEmail ->
            ( { model
                | parsedEmail = Just (parseEmail model.form.email)
              }
            , Cmd.none
            )

        ValidatePassword ->
            ( { model
                | parsedPassword = Just (parsePassword model.form.password)
              }
            , Cmd.none
            )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Login"
    , content =
        main_ [ Attr.class "", Attr.tabindex -1 ]
            [ div [ Attr.class "min-h-full flex flex-col items-center py-12" ]
                [ div [ Attr.class "mb-12" ]
                    [ h2 [ Attr.class "text-3xl font-bold text-center text-gray-900" ]
                        [ text "Log in to your account"
                        ]
                    ]
                , div [ Attr.class "max-w-md w-full" ]
                    [ form
                        [ Attr.class "grid grid-cols-1 gap-6"
                        , Events.onSubmit SubmitForm
                        ]
                        [ div [ Attr.class "" ]
                            [ label [ Attr.for "email" ]
                                [ text "Email" ]
                            , input
                                [ Attr.class "w-full border-gray-300 rounded-md"
                                , Attr.attribute "autocomplete" "email"
                                , Attr.autofocus True
                                , Attr.id "email"
                                , Attr.type_ "email"
                                , Attr.value model.form.email
                                , Events.onBlur ValidateEmail
                                , Events.onInput EmailChanged
                                ]
                                []
                            , span [ Attr.class "text-red-500" ]
                                [ case model.parsedEmail of
                                    Just (InvalidEmail msg) ->
                                        text msg

                                    Just (EmptyEmail msg) ->
                                        text msg

                                    _ ->
                                        Html.Extra.nothing
                                ]
                            ]
                        , div [ Attr.class "" ]
                            [ div [ Attr.class "flex items-center justify-between" ]
                                [ label [ Attr.for "password" ]
                                    [ text "Password" ]
                                , div
                                    [ Attr.class "cursor-pointer text-gray-800"
                                    , Events.onClick ToggleShowPassword
                                    ]
                                    [ if model.showPassword then
                                        Icon.defaults
                                            |> Icon.withSize 20
                                            |> Icon.eyeClose

                                      else
                                        Icon.defaults
                                            |> Icon.withSize 20
                                            |> Icon.eyeOpen
                                    ]
                                ]
                            , input
                                [ Attr.class "w-full border-gray-300 rounded-md"
                                , Attr.attribute "autocomplete" "current-password"
                                , Attr.id "password"
                                , Attr.type_
                                    (if model.showPassword then
                                        "text"

                                     else
                                        "password"
                                    )
                                , Attr.value model.form.password
                                , Events.onBlur ValidatePassword
                                , Events.onInput PasswordChanged
                                ]
                                []
                            , span [ Attr.class "text-red-500" ]
                                [ case model.parsedPassword of
                                    Just (EmptyPassword msg) ->
                                        text msg

                                    _ ->
                                        Html.Extra.nothing
                                ]
                            ]
                        , div [ Attr.class "flex items-center justify-between" ]
                            [ div [ Attr.class "flex items-center" ]
                                [ input
                                    [ Attr.class "rounded text-indigo-600 focus:ring-indigo-500 border-gray-300"
                                    , Attr.id "remember_me"
                                    , Attr.type_ "checkbox"
                                    , Attr.checked model.form.rememberMe
                                    , Events.onClick ToggleRememberMe
                                    ]
                                    []
                                , label [ Attr.class "ml-2 block text-sm text-gray-900" ]
                                    [ text "Remember me" ]
                                ]
                            , div [ Attr.class "text-sm" ]
                                [ a
                                    [ Attr.class "font-medium text-indigo-600 hover:text-indigo-500"
                                    , Attr.href ""
                                    ]
                                    [ text "Forgot your password?" ]
                                ]
                            ]
                        , div [ Attr.class "" ]
                            [ button [ Attr.class "flex w-full justify-center py-2 px-4 border border-transparent rounded-md text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" ]
                                [ text "Log in" ]
                            ]
                        ]
                    ]
                ]
            ]
    }



-- FORM


type alias Form =
    { email : String
    , password : String
    , rememberMe : Bool
    }


type Email
    = EmptyEmail String
    | InvalidEmail String
    | ValidEmail String


parseEmail : String -> Email
parseEmail str =
    if String.isEmpty str then
        EmptyEmail "Email is required."

    else if not (String.contains "@" str) then
        InvalidEmail "Must have the @ sign and no spaces."

    else
        ValidEmail str


type Password
    = EmptyPassword String
    | ValidPassword String


parsePassword : String -> Password
parsePassword str =
    if String.isEmpty str then
        EmptyPassword "Password is required."

    else
        ValidPassword str


session : Model -> Session.Session
session model =
    model.session
