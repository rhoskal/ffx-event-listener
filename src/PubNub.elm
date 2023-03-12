module PubNub exposing
    ( Event
    , EventContext
    , EventDomain(..)
    , EventTopic(..)
    , SubscriptionCreds
    , auth
    , domainToString
    , topicToString
    )

import Api exposing (Cred)
import Api.Endpoint as Endpoint
import EnvironmentId exposing (EnvironmentId)
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
    { id : String
    , domain : EventDomain
    , topic : EventTopic
    , context : EventContext
    , payload : Decode.Value
    , createdAt : Maybe Time.Posix
    }


type EventDomain
    = FileDomain
    | JobDomain
    | SpaceDomain
    | WorkbookDomain


type EventTopic
    = ActionTriggered
    | JobCompleted
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



-- HELPERS


domainToString : EventDomain -> String
domainToString domain =
    case domain of
        FileDomain ->
            "File"

        JobDomain ->
            "Job"

        SpaceDomain ->
            "Space"

        WorkbookDomain ->
            "Workspace"


topicToString : EventTopic -> String
topicToString topic =
    case topic of
        ActionTriggered ->
            "action:triggered"

        JobCompleted ->
            "job:completed"

        JobDeleted ->
            "job:deleted"

        JobFailed ->
            "job:failed"

        JobStarted ->
            "job:started"

        JobUpdated ->
            "job:updated"

        JobWaiting ->
            "job:waiting"

        RecordsCreated ->
            "records:created"

        RecordsDeleted ->
            "records:deleted"

        RecordsUpdated ->
            "records:updated"

        SheetValidated ->
            "sheet:validated"

        SpaceAdded ->
            "space:added"

        SpaceRemoved ->
            "space:removed"

        UploadCompleted ->
            "upload:completed"

        UploadFailed ->
            "upload:failed"

        UploadStarted ->
            "upload:started"

        UserAdded ->
            "user:added"

        UserOffline ->
            "user:offline"

        UserOnline ->
            "user:online"

        UserRemoved ->
            "user:removed"

        WorkbookAdded ->
            "workbook:added"

        WorkbookRemoved ->
            "workbook:removed"
