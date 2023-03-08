module Api.Endpoint exposing
    ( Endpoint
    , auth
    , listEnvironments
    , listSpaces
    , pubNubAuth
    , request
    )

import Http exposing (Body, Expect, Header)
import Url.Builder exposing (QueryParameter)


type Endpoint
    = Endpoint String


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


pubNubAuth : String -> Endpoint
pubNubAuth spaceId =
    url [ "spaces", spaceId, "subscription" ] []
