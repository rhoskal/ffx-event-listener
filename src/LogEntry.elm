module LogEntry exposing
    ( LogEntry
    , list
    )

import Api
import Api.Endpoint as Endpoint
import EnvironmentId
import EventId
import Json.Decode as D
import Json.Decode.Pipeline exposing (required)
import RemoteData as RD
import Time
import Timestamp


type alias LogEntry =
    { eventId : EventId.EventId
    , success : Bool
    , createdAt : Time.Posix
    , content : String
    }



-- HTTPS


list :
    EnvironmentId.EnvironmentId
    -> Maybe Api.Cred
    -> (RD.WebData (List LogEntry) -> msg)
    -> Cmd msg
list environmentId maybeCred toMsg =
    let
        envId : String
        envId =
            EnvironmentId.toString environmentId
    in
    Api.get (Endpoint.listLogEntries envId) maybeCred toMsg listDecoder



-- JSON


listDecoder : D.Decoder (List LogEntry)
listDecoder =
    D.at [ "data" ] (D.list decoder)


decoder : D.Decoder LogEntry
decoder =
    D.succeed LogEntry
        |> required "eventId" EventId.decoder
        |> required "success" D.bool
        |> required "createdAt" Timestamp.decoder
        |> required "log" D.string
