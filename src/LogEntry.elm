module LogEntry exposing
    ( LogEntry
    , list
    )

import Api exposing (Cred)
import Api.Endpoint as Endpoint
import EnvironmentId exposing (EnvironmentId)
import EventId exposing (EventId)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import RemoteData exposing (WebData)
import Time exposing (Posix)
import Timestamp


type alias LogEntry =
    { eventId : EventId
    , success : Bool
    , createdAt : Posix
    , content : String
    }



-- HTTPS


list : EnvironmentId -> Maybe Cred -> (WebData (List LogEntry) -> msg) -> Cmd msg
list environmentId maybeCred toMsg =
    let
        envId : String
        envId =
            EnvironmentId.toString environmentId
    in
    Api.get (Endpoint.listLogEntries envId) maybeCred toMsg logEntriesDecoder



-- DECODERS


logEntriesDecoder : Decoder (List LogEntry)
logEntriesDecoder =
    Decode.at [ "data" ] (Decode.list logEntryDecoder)


logEntryDecoder : Decoder LogEntry
logEntryDecoder =
    Decode.succeed LogEntry
        |> required "eventId" EventId.decoder
        |> required "success" Decode.bool
        |> required "createdAt" Timestamp.decoder
        |> required "log" Decode.string
