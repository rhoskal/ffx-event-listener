module Agent exposing
    ( Agent
    , list
    )

import AgentId exposing (AgentId)
import Api exposing (Cred)
import Api.Endpoint as Endpoint
import EnvironmentId exposing (EnvironmentId)
import EventTopic exposing (EventTopic)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import RemoteData exposing (WebData)


type alias Agent =
    { id : AgentId
    , topics : Maybe (List EventTopic)
    }



-- HTTP


list : EnvironmentId -> Maybe Cred -> (WebData (List Agent) -> msg) -> Cmd msg
list environmentId maybeCred toMsg =
    let
        envId : String
        envId =
            EnvironmentId.toString environmentId
    in
    Api.get (Endpoint.listAgents envId) maybeCred toMsg agentsDecoder



-- DECODERS


agentsDecoder : Decoder (List Agent)
agentsDecoder =
    Decode.at [ "data" ] (Decode.list agentDecoder)


agentDecoder : Decoder Agent
agentDecoder =
    Decode.succeed Agent
        |> required "id" AgentId.decoder
        |> optional "topics" (Decode.maybe (Decode.list EventTopic.decoder)) Nothing
