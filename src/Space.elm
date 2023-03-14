module Space exposing
    ( Space
    , list
    , spaceDecoder
    )

import Api exposing (Cred)
import Api.Endpoint as Endpoint
import EnvironmentId exposing (EnvironmentId)
import Iso8601
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import RemoteData exposing (WebData)
import SpaceId exposing (SpaceId)
import Time


type alias Space =
    { id : SpaceId
    , workbooksCount : Maybe Int
    , filesCount : Maybe Int
    , createdByUserName : Maybe String
    , createdAt : Maybe Time.Posix
    , spaceConfigId : String
    , environmentId : EnvironmentId
    , name : Maybe String
    }



-- HTTP


list : EnvironmentId -> Maybe Cred -> (WebData (List Space) -> msg) -> Cmd msg
list environmentId maybeCred toMsg =
    let
        envId : String
        envId =
            EnvironmentId.toString environmentId
    in
    Api.get (Endpoint.listSpaces envId) maybeCred toMsg spacesDecoder



-- DECODERS


spacesDecoder : Decoder (List Space)
spacesDecoder =
    Decode.at [ "data" ] (Decode.list spaceDecoder)


spaceDecoder : Decoder Space
spaceDecoder =
    Decode.succeed Space
        |> required "id" SpaceId.decoder
        |> optional "workbooksCount" (Decode.maybe Decode.int) Nothing
        |> optional "filesCount" (Decode.maybe Decode.int) Nothing
        |> optional "createdByUserName" (Decode.maybe Decode.string) Nothing
        |> optional "createdAt" (Decode.maybe Iso8601.decoder) Nothing
        |> required "spaceConfigId" Decode.string
        |> required "environmentId" EnvironmentId.decoder
        |> optional "name" (Decode.maybe Decode.string) Nothing
