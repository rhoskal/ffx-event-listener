module PubNub exposing
    ( Event
    , EventContext
    , SubscriptionCreds
    , auth
    )

import Api
import Api.Endpoint as Endpoint
import EnvironmentId
import EventDomain
import EventId
import EventTopic
import Json.Decode as D
import Json.Decode.Pipeline exposing (required)
import RemoteData as RD
import SpaceId
import Time


type alias SubscriptionCreds =
    { accountId : String
    , subscribeKey : String
    , token : String
    }


type alias Event =
    { id : EventId.EventId
    , domain : EventDomain.EventDomain
    , topic : EventTopic.EventTopic
    , context : EventContext
    , payload : D.Value
    , createdAt : Time.Posix
    }


type alias EventContext =
    { actionName : Maybe String
    , accountId : String
    , environmentId : EnvironmentId.EnvironmentId
    , spaceId : Maybe SpaceId.SpaceId
    , workbookId : Maybe String
    , sheetId : Maybe String
    , sheetSlug : Maybe String
    , versionId : Maybe String
    , jobId : Maybe String
    , fileId : Maybe String
    , proceedingEventId : Maybe String
    , actorId : Maybe String
    }



-- HTTP


auth :
    SpaceId.SpaceId
    -> Maybe Api.Cred
    -> (RD.WebData SubscriptionCreds -> msg)
    -> Cmd msg
auth spaceId maybeCred toMsg =
    Api.get (Endpoint.pubNubAuth <| SpaceId.toString spaceId) maybeCred toMsg credDecoder



-- JSON


credDecoder : D.Decoder SubscriptionCreds
credDecoder =
    D.at [ "data" ]
        (D.succeed SubscriptionCreds
            |> required "accountId" D.string
            |> required "subscribeKey" D.string
            |> required "token" D.string
        )
