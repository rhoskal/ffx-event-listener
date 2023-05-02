module Api exposing (Cred, credParser, get)

{-| This module exposes wrappers around Http methods
-}

import Api.Endpoint as Endpoint
import Http
import Json.Decode as D
import RemoteData as RD



-- CRED


{-| The authentication credentials for the Viewer.
-}
type Cred
    = Cred String


token : Cred -> String
token (Cred val) =
    val


credHeader : Cred -> Http.Header
credHeader cred =
    Http.header "authorization" ("Bearer " ++ token cred)


credParser : String -> Result String Cred
credParser input =
    if String.startsWith "sk_" input then
        Ok (Cred input)

    else
        Err "Wrong format"



-- HTTP


get :
    Endpoint.Endpoint
    -> Maybe Cred
    -> (RD.WebData a -> msg)
    -> D.Decoder a
    -> Cmd msg
get url maybeCred toMsg decoder =
    Endpoint.request
        { body = Http.emptyBody
        , expect = Http.expectJson (RD.fromResult >> toMsg) decoder
        , headers =
            case maybeCred of
                Just cred ->
                    [ credHeader cred ]

                Nothing ->
                    []
        , method = "GET"
        , timeout = Nothing
        , tracker = Nothing
        , url = url
        }



-- post :
--     Endpoint.Endpoint
--     -> Maybe Cred
--     -> Http.Body
--     -> (RD.WebData a -> msg)
--     -> D.Decoder a
--     -> Cmd msg
-- post url maybeCred body toMsg decoder =
--     Endpoint.request
--         { body = body
--         , expect = Http.expectJson (RD.fromResult >> toMsg) decoder
--         , headers =
--             case maybeCred of
--                 Just cred ->
--                     [ credHeader cred ]
--                 Nothing ->
--                     []
--         , method = "POST"
--         , timeout = Nothing
--         , tracker = Nothing
--         , url = url
--         }
