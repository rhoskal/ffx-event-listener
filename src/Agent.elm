module Agent exposing
    ( Agent
    , list
    )

import AgentId
import Api
import Api.Endpoint as Endpoint
import EnvironmentId
import EventTopic
import Json.Decode as D
import Json.Decode.Pipeline exposing (optional, required)
import RemoteData as RD


type alias Agent =
    { id : AgentId.AgentId
    , topics : Maybe (List EventTopic.EventTopic)
    }



-- HTTP


list :
    EnvironmentId.EnvironmentId
    -> Maybe Api.Cred
    -> (RD.WebData (List Agent) -> msg)
    -> Cmd msg
list environmentId maybeCred toMsg =
    let
        envId : String
        envId =
            EnvironmentId.toString environmentId
    in
    Api.get (Endpoint.listAgents envId) maybeCred toMsg listDecoder



-- JSON


listDecoder : D.Decoder (List Agent)
listDecoder =
    D.at [ "data" ] (D.list decoder)


decoder : D.Decoder Agent
decoder =
    D.succeed Agent
        |> required "id" AgentId.decoder
        |> optional "topics" (D.maybe (D.list EventTopic.decoder)) Nothing
