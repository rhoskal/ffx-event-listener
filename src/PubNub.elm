module PubNub exposing
    ( Event
    , EventContext
    , SubscriptionCreds
    , auth
    )

import Api exposing (Cred)
import Api.Endpoint as Endpoint
import EnvironmentId exposing (EnvironmentId)
import EventDomain exposing (EventDomain)
import EventId exposing (EventId)
import EventTopic exposing (EventTopic)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import RemoteData exposing (WebData)
import SpaceId exposing (SpaceId)
import Time


type alias SubscriptionCreds =
    { accountId : String
    , subscribeKey : String
    , token : String
    }


type alias Event =
    { id : EventId
    , domain : EventDomain
    , topic : EventTopic
    , context : EventContext
    , payload : Decode.Value
    , createdAt : Maybe Time.Posix
    }


type alias EventContext =
    { actionName : Maybe String
    , accountId : String
    , environmentId : EnvironmentId
    , spaceId : Maybe SpaceId
    , workbookId : Maybe String
    , sheetId : Maybe String
    , sheetSlug : Maybe String
    , versionId : Maybe String
    , jobId : Maybe String
    , fileId : Maybe String
    , proceedingEventId : Maybe String
    }



-- HTTP


auth : SpaceId -> Maybe Cred -> (WebData SubscriptionCreds -> msg) -> Cmd msg
auth spaceId maybeCred toMsg =
    Api.get (Endpoint.pubNubAuth <| SpaceId.toString spaceId) maybeCred toMsg subscriptionCredsDecoder



-- DECODERS


subscriptionCredsDecoder : Decoder SubscriptionCreds
subscriptionCredsDecoder =
    let
        decoder : Decoder SubscriptionCreds
        decoder =
            Decode.succeed SubscriptionCreds
                |> required "accountId" Decode.string
                |> required "subscribeKey" Decode.string
                |> required "token" Decode.string
    in
    Decode.at [ "data" ] decoder
