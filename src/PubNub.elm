module PubNub exposing
    ( Context
    , Domain(..)
    , DomainEvent
    , SubscriptionCreds
    , Topic(..)
    , auth
    )

-- import Iso8601
-- import Time

import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Environment exposing (EnvironmentId)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import RemoteData exposing (WebData)
import Space exposing (SpaceId)


type alias SubscriptionCreds =
    { accountId : String
    , subscribeKey : String
    , token : String
    }


type alias DomainEvent =
    { id : String
    , domain : Domain
    , topic : Topic
    , context : Context
    , payload : Decode.Value

    -- , createdAt : Maybe Time.Posix
    , createdAt : Maybe String
    }


type Domain
    = File
    | Job
    | Space
    | Workbook


type Topic
    = JobCompleted
    | JobDeleted
    | JobFailed
    | JobStarted
    | JobUpdated
    | JobWaiting
    | RecordsCreated
    | RecordsDeleted
    | RecordsUpdated
    | SheetValidated
    | SpaceAdded
    | SpaceRemoved
    | UploadCompleted
    | UploadFailed
    | UploadStarted
    | UserAdded
    | UserOffline
    | UserOnline
    | UserRemoved
    | WorkbookAdded
    | WorkbookRemoved


type alias Context =
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
    Api.get (Endpoint.pubNubAuth <| Space.unwrap spaceId) maybeCred toMsg subscriptionCredsDecoder



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
