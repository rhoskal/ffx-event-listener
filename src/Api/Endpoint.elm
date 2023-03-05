module Api.Endpoint exposing
    ( AccessToken
    , Endpoint
    , Environment
    , Space
    , SubscriptionCreds
    , auth
    , authDecoder
    , environmentsDecoder
    , getSubscriptionCreds
    , listEnvironments
    , listSpaces
    , request
    , spacesDecoder
    , subscriptionCredsDecoder
    )

import Http exposing (Body, Expect, Header)
import Json.Decode as Decode
    exposing
        ( Decoder
        , at
        , int
        , list
        , maybe
        , string
        , succeed
        )
import Json.Decode.Pipeline exposing (optional, required, requiredAt)
import Url.Builder exposing (QueryParameter)


type Endpoint
    = Endpoint String


type AccessToken
    = AccessToken String


type alias Environment =
    { id : String
    , accountId : String
    , name : String
    }


type alias Space =
    { id : String
    , workbooksCount : Maybe Int
    , filesCount : Maybe Int
    , createdByUserName : Maybe String
    , createdAt : Maybe String
    , environmentId : String
    , name : Maybe String
    }


type alias SubscriptionCreds =
    { accountId : String
    , subscribeKey : String
    , token : String
    }


{-| Http.request, except it takes an Endpoint instead of a Url.
-}
request :
    { body : Body
    , expect : Expect msg
    , headers : List Header
    , method : String
    , timeout : Maybe Float
    , tracker : Maybe String
    , url : Endpoint
    }
    -> Cmd msg
request config =
    Http.request
        { body = config.body
        , expect = config.expect
        , headers = config.headers
        , method = config.method
        , timeout = config.timeout
        , tracker = config.tracker
        , url = unwrap config.url
        }



-- PRIVATE


unwrap : Endpoint -> String
unwrap (Endpoint str) =
    str


url : List String -> List QueryParameter -> Endpoint
url paths queryParams =
    Url.Builder.crossOrigin "https://api.x.flatfile.com/v1" paths queryParams
        |> Endpoint



-- ENDPOINTS


auth : Endpoint
auth =
    url [ "auth", "access-token" ] []


listEnvironments : Endpoint
listEnvironments =
    url [ "environments" ] []


listSpaces : String -> Endpoint
listSpaces environmentId =
    url [ "spaces" ]
        [ Url.Builder.string "environmentId" environmentId
        , Url.Builder.string "sortDirection" "desc"
        , Url.Builder.string "sortField" "createdAt"
        , Url.Builder.int "pageSize" 10
        ]


getSubscriptionCreds : String -> Endpoint
getSubscriptionCreds spaceId =
    url [ "spaces", spaceId, "subscription" ] []



-- DECODERS


authDecoder : Decoder AccessToken
authDecoder =
    let
        decoder : Decoder AccessToken
        decoder =
            succeed AccessToken
                |> required "accessToken" string
    in
    at [ "data" ] decoder


environmentsDecoder : Decoder (List Environment)
environmentsDecoder =
    at [ "data" ] (list environmentDecoder)


environmentDecoder : Decoder Environment
environmentDecoder =
    succeed Environment
        |> required "id" string
        |> required "accountId" string
        |> required "name" string


spacesDecoder : Decoder (List Space)
spacesDecoder =
    at [ "data" ] (list spaceDecoder)


spaceDecoder : Decoder Space
spaceDecoder =
    succeed Space
        |> required "id" string
        |> optional "workbooksCount" (maybe int) Nothing
        |> optional "filesCount" (maybe int) Nothing
        |> optional "createdByUserName" (maybe string) Nothing
        |> optional "createdAt" (maybe string) Nothing
        |> required "environmentId" string
        |> optional "name" (maybe string) Nothing


subscriptionCredsDecoder : Decoder SubscriptionCreds
subscriptionCredsDecoder =
    let
        decoder : Decoder SubscriptionCreds
        decoder =
            succeed SubscriptionCreds
                |> required "accountId" string
                |> required "subscribeKey" string
                |> required "token" string
    in
    at [ "data" ] decoder
