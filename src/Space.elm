module Space exposing
    ( Space
    , SpaceId(..)
    , list
    , spaceDecoder
    , spaceIdDecoder
    , unwrap
    )

import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Environment exposing (EnvironmentId, environmentIdDecoder)
import Iso8601
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import RemoteData exposing (WebData)
import Time


type SpaceId
    = SpaceId String


type alias Space =
    { id : SpaceId
    , workbooksCount : Maybe Int
    , filesCount : Maybe Int
    , createdByUserName : Maybe String
    , createdAt : Maybe Time.Posix
    , environmentId : EnvironmentId
    , name : Maybe String
    }


unwrap : SpaceId -> String
unwrap (SpaceId id) =
    id



-- HTTP


list : EnvironmentId -> Maybe Cred -> (WebData (List Space) -> msg) -> Cmd msg
list environmentId maybeCred toMsg =
    let
        envId : String
        envId =
            Environment.unwrap environmentId
    in
    Api.get (Endpoint.listSpaces envId) maybeCred toMsg spacesDecoder



-- DECODERS


spacesDecoder : Decoder (List Space)
spacesDecoder =
    Decode.at [ "data" ] (Decode.list spaceDecoder)


spaceDecoder : Decoder Space
spaceDecoder =
    Decode.succeed Space
        |> required "id" spaceIdDecoder
        |> optional "workbooksCount" (Decode.maybe Decode.int) Nothing
        |> optional "filesCount" (Decode.maybe Decode.int) Nothing
        |> optional "createdByUserName" (Decode.maybe Decode.string) Nothing
        |> optional "createdAt" (Decode.maybe Iso8601.decoder) Nothing
        |> required "environmentId" environmentIdDecoder
        |> optional "name" (Decode.maybe Decode.string) Nothing


spaceIdDecoder : Decoder SpaceId
spaceIdDecoder =
    Decode.map SpaceId Decode.string
