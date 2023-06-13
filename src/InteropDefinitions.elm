module InteropDefinitions exposing
    ( Flags
    , FromElm(..)
    , ToElm(..)
    , interop
    )

import EnvironmentId
import EventDomain
import EventId
import EventTopic
import Iso8601
import PubNub
import SpaceId
import Time
import TsJson.Decode as TsDecode
import TsJson.Decode.Pipeline exposing (optional, required)
import TsJson.Encode as TsEncode


interop :
    { toElm : TsDecode.Decoder ToElm
    , fromElm : TsEncode.Encoder FromElm
    , flags : TsDecode.Decoder Flags
    }
interop =
    { toElm = toElm
    , fromElm = fromElm
    , flags = flags
    }


type FromElm
    = OpenExternalLink String
    | ReportIssue String
    | UsePubNubCreds
        { accountId : String
        , spaceId : SpaceId.SpaceId
        , subscribeKey : String
        , token : String
        }


type ToElm
    = PNDomainEvent PubNub.Event


type alias Flags =
    {}



-- ENCODERS


fromElm : TsEncode.Encoder FromElm
fromElm =
    TsEncode.union
        (\vExternalLink vReportIssue vPubNubCreds value ->
            case value of
                OpenExternalLink string ->
                    vExternalLink string

                ReportIssue string ->
                    vReportIssue string

                UsePubNubCreds creds ->
                    vPubNubCreds creds
        )
        |> TsEncode.variantTagged "openExternalLink"
            (TsEncode.object
                [ TsEncode.required "url" identity TsEncode.string ]
            )
        |> TsEncode.variantTagged "reportIssue"
            (TsEncode.object
                [ TsEncode.required "message" identity TsEncode.string ]
            )
        |> TsEncode.variantTagged "subscriptionCreds"
            (TsEncode.object
                [ TsEncode.required "accountId" .accountId TsEncode.string
                , TsEncode.required "spaceId" .spaceId (TsEncode.map SpaceId.toString TsEncode.string)
                , TsEncode.required "subscribeKey" .subscribeKey TsEncode.string
                , TsEncode.required "token" .token TsEncode.string
                ]
            )
        |> TsEncode.buildUnion



-- DECODERS


toElm : TsDecode.Decoder ToElm
toElm =
    TsDecode.map PNDomainEvent domainEventDecoder


domainEventDecoder : TsDecode.Decoder PubNub.Event
domainEventDecoder =
    TsDecode.succeed PubNub.Event
        |> required "id" eventIdDecoder
        |> required "domain" domainDecoder
        |> required "topic" topicDecoder
        |> required "context" contextDecoder
        |> required "payload" TsDecode.value
        |> required "createdAt" posixFromIso8601Decoder


eventIdDecoder : TsDecode.Decoder EventId.EventId
eventIdDecoder =
    TsDecode.map EventId.wrap TsDecode.string


domainDecoder : TsDecode.Decoder EventDomain.EventDomain
domainDecoder =
    TsDecode.stringUnion
        [ ( "file", EventDomain.FileDomain )
        , ( "job", EventDomain.JobDomain )
        , ( "space", EventDomain.SpaceDomain )
        , ( "workbook", EventDomain.WorkbookDomain )
        ]


topicDecoder : TsDecode.Decoder EventTopic.EventTopic
topicDecoder =
    TsDecode.stringUnion
        [ ( "agent:created", EventTopic.AgentCreated )
        , ( "agent:deleted", EventTopic.AgentDeleted )
        , ( "agent:updated", EventTopic.AgentUpdated )
        , ( "commit:created", EventTopic.CommitCreated )
        , ( "commit:updated", EventTopic.CommitUpdated )
        , ( "document:created", EventTopic.DocumentCreated )
        , ( "document:deleted", EventTopic.DocumentDeleted )
        , ( "document:updated", EventTopic.DocumentUpdated )
        , ( "file:created", EventTopic.FileCreated )
        , ( "file:deleted", EventTopic.FileDeleted )
        , ( "file:updated", EventTopic.FileUpdated )
        , ( "job:completed", EventTopic.JobCompleted )
        , ( "job:created", EventTopic.JobCreated )
        , ( "job:deleted", EventTopic.JobDeleted )
        , ( "job:failed", EventTopic.JobFailed )
        , ( "job:outcome:outcome-acknowledged", EventTopic.JobOutcomeAck )
        , ( "job:ready", EventTopic.JobReady )
        , ( "job:scheduled", EventTopic.JobScheduled )
        , ( "job:updated", EventTopic.JobUpdated )
        , ( "layer:created", EventTopic.LayerCreated )
        , ( "record:created", EventTopic.RecordCreated )
        , ( "record:deleted", EventTopic.RecordDeleted )
        , ( "record:updated", EventTopic.RecordUpdated )
        , ( "sheet:created", EventTopic.SheetCreated )
        , ( "sheet:deleted", EventTopic.SheetDeleted )
        , ( "sheet:updated", EventTopic.SheetUpdated )
        , ( "space:created", EventTopic.SpaceCreated )
        , ( "space:deleted", EventTopic.SpaceDeleted )
        , ( "space:updated", EventTopic.SpaceUpdated )
        , ( "workbook:created", EventTopic.WorkbookCreated )
        , ( "workbook:deleted", EventTopic.WorkbookDeleted )
        , ( "workbook:updated", EventTopic.WorkbookUpdated )
        ]


contextDecoder : TsDecode.Decoder PubNub.EventContext
contextDecoder =
    TsDecode.succeed PubNub.EventContext
        |> optional "actionName" (TsDecode.maybe TsDecode.string) Nothing
        |> required "accountId" TsDecode.string
        |> required "environmentId" environmentIdDecoder
        |> optional "spaceId" (TsDecode.maybe spaceIdDecoder) Nothing
        |> optional "workbookId" (TsDecode.maybe TsDecode.string) Nothing
        |> optional "sheetId" (TsDecode.maybe TsDecode.string) Nothing
        |> optional "sheetSlug" (TsDecode.maybe TsDecode.string) Nothing
        |> optional "versionId" (TsDecode.maybe TsDecode.string) Nothing
        |> optional "jobId" (TsDecode.maybe TsDecode.string) Nothing
        |> optional "fileId" (TsDecode.maybe TsDecode.string) Nothing
        |> optional "procedingEventId" (TsDecode.maybe TsDecode.string) Nothing
        |> optional "actorId" (TsDecode.maybe TsDecode.string) Nothing


environmentIdDecoder : TsDecode.Decoder EnvironmentId.EnvironmentId
environmentIdDecoder =
    TsDecode.map EnvironmentId.wrap TsDecode.string


spaceIdDecoder : TsDecode.Decoder SpaceId.SpaceId
spaceIdDecoder =
    TsDecode.map SpaceId.wrap TsDecode.string


posixFromIso8601Decoder : TsDecode.Decoder Time.Posix
posixFromIso8601Decoder =
    let
        decoder : TsDecode.Decoder (String -> Time.Posix)
        decoder =
            TsDecode.succeed <|
                (Iso8601.toTime >> Result.withDefault (Time.millisToPosix 0))
    in
    TsDecode.andMap TsDecode.string decoder


flags : TsDecode.Decoder Flags
flags =
    TsDecode.null {}
