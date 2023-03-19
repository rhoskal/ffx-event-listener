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
        |> optional "createdAt" (TsDecode.maybe posixFromIso8601Decoder) Nothing


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
        [ ( "action:triggered", EventTopic.ActionTriggered )
        , ( "job:completed", EventTopic.JobCompleted )
        , ( "job:deleted", EventTopic.JobDeleted )
        , ( "job:failed", EventTopic.JobFailed )
        , ( "job:started", EventTopic.JobStarted )
        , ( "job:updated", EventTopic.JobUpdated )
        , ( "job:waiting", EventTopic.JobWaiting )
        , ( "records:created", EventTopic.RecordsCreated )
        , ( "records:deleted", EventTopic.RecordsDeleted )
        , ( "records:updated", EventTopic.RecordsUpdated )
        , ( "sheet:validated", EventTopic.SheetValidated )
        , ( "space:added", EventTopic.SpaceAdded )
        , ( "space:removed", EventTopic.SpaceRemoved )
        , ( "upload:completed", EventTopic.UploadCompleted )
        , ( "upload:failed", EventTopic.UploadFailed )
        , ( "upload:started", EventTopic.UploadStarted )
        , ( "user:added", EventTopic.UserAdded )
        , ( "user:offline", EventTopic.UserOffline )
        , ( "user:online", EventTopic.UserOnline )
        , ( "user:removed", EventTopic.UserRemoved )
        , ( "workbook:added", EventTopic.WorkbookAdded )
        , ( "workbook:removed", EventTopic.WorkbookRemoved )
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
