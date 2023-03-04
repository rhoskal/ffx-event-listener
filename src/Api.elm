module Api exposing (get, post)

{-| This module exposes wrappers around Http methods
-}

import Api.Endpoint as Endpoint exposing (Endpoint)
import Http exposing (Body)
import Json.Decode exposing (Decoder)
import RemoteData as RD exposing (WebData)


get : Endpoint -> (WebData a -> msg) -> Decoder a -> Cmd msg
get url toMsg decoder =
    Endpoint.request
        { body = Http.emptyBody
        , expect = Http.expectJson (RD.fromResult >> toMsg) decoder
        , headers = []
        , method = "GET"
        , timeout = Nothing
        , tracker = Nothing
        , url = url
        }


post : Endpoint -> Body -> (WebData a -> msg) -> Decoder a -> Cmd msg
post url body toMsg decoder =
    Endpoint.request
        { body = body
        , expect = Http.expectJson (RD.fromResult >> toMsg) decoder
        , headers = []
        , method = "POST"
        , timeout = Nothing
        , tracker = Nothing
        , url = url
        }
