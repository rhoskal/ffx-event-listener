module Space exposing
    ( Space
    , decoder
    , list
    )

import Api
import Api.Endpoint as Endpoint
import EnvironmentId
import Json.Decode as D
import Json.Decode.Pipeline exposing (optional, required)
import RemoteData as RD
import SpaceId
import Time
import Timestamp


type alias Space =
    { id : SpaceId.SpaceId
    , workbooksCount : Maybe Int
    , filesCount : Maybe Int
    , createdByUserName : Maybe String
    , createdAt : Time.Posix
    , spaceConfigId : Maybe String
    , environmentId : EnvironmentId.EnvironmentId
    , name : Maybe String
    }



-- HTTP


list :
    EnvironmentId.EnvironmentId
    -> Maybe Api.Cred
    -> (RD.WebData (List Space) -> msg)
    -> Cmd msg
list environmentId maybeCred toMsg =
    let
        envId : String
        envId =
            EnvironmentId.toString environmentId
    in
    Api.get (Endpoint.listSpaces envId) maybeCred toMsg listDecoder



-- JSON


listDecoder : D.Decoder (List Space)
listDecoder =
    D.at [ "data" ] (D.list decoder)


decoder : D.Decoder Space
decoder =
    D.succeed Space
        |> required "id" SpaceId.decoder
        |> optional "workbooksCount" (D.maybe D.int) Nothing
        |> optional "filesCount" (D.maybe D.int) Nothing
        |> optional "createdByUserName" (D.maybe D.string) Nothing
        |> required "createdAt" Timestamp.decoder
        |> required "spaceConfigId" (D.maybe D.string)
        |> required "environmentId" EnvironmentId.decoder
        |> optional "name" (D.maybe D.string) Nothing
