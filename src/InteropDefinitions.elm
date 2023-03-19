module InteropDefinitions exposing
    ( Flags
    , FromElm(..)
    , ToElm(..)
    , interop
    )

import Api
import EnvironmentId
import EventDomain
import EventId
import EventTopic
import Iso8601
import PubNub
import SpaceId
import Time
import TsJson.Decode as D
import TsJson.Decode.Pipeline exposing (optional, required)
import TsJson.Encode as E


interop :
    { toElm : D.Decoder ToElm
    , fromElm : E.Encoder FromElm
    , flags : D.Decoder Flags
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



-- type alias Flags =
--     { accessToken : Maybe String
--     }


type alias Flags =
    { accessToken : Maybe Api.Cred
    }



-- ENCODERS


fromElm : E.Encoder FromElm
fromElm =
    E.union
        (\vExternalLink vReportIssue vPubNubCreds value ->
            case value of
                OpenExternalLink string ->
                    vExternalLink string

                ReportIssue string ->
                    vReportIssue string

                UsePubNubCreds creds ->
                    vPubNubCreds creds
        )
        |> E.variantTagged "openExternalLink"
            (E.object
                [ E.required "url" identity E.string ]
            )
        |> E.variantTagged "reportIssue"
            (E.object
                [ E.required "message" identity E.string ]
            )
        |> E.variantTagged "subscriptionCreds"
            (E.object
                [ E.required "accountId" .accountId E.string
                , E.required "spaceId" .spaceId (E.map SpaceId.toString E.string)
                , E.required "subscribeKey" .subscribeKey E.string
                , E.required "token" .token E.string
                ]
            )
        |> E.buildUnion



-- DECODERS


toElm : D.Decoder ToElm
toElm =
    D.map PNDomainEvent domainEventDecoder


domainEventDecoder : D.Decoder PubNub.Event
domainEventDecoder =
    D.succeed PubNub.Event
        |> required "id" eventIdDecoder
        |> required "domain" domainDecoder
        |> required "topic" topicDecoder
        |> required "context" contextDecoder
        |> required "payload" D.value
        |> optional "createdAt" (D.maybe posixFromIso8601Decoder) Nothing


eventIdDecoder : D.Decoder EventId.EventId
eventIdDecoder =
    D.map EventId.wrap D.string


domainDecoder : D.Decoder EventDomain.EventDomain
domainDecoder =
    D.stringUnion
        [ ( "file", EventDomain.FileDomain )
        , ( "job", EventDomain.JobDomain )
        , ( "space", EventDomain.SpaceDomain )
        , ( "workbook", EventDomain.WorkbookDomain )
        ]


topicDecoder : D.Decoder EventTopic.EventTopic
topicDecoder =
    D.stringUnion
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


contextDecoder : D.Decoder PubNub.EventContext
contextDecoder =
    D.succeed PubNub.EventContext
        |> optional "actionName" (D.maybe D.string) Nothing
        |> required "accountId" D.string
        |> required "environmentId" environmentIdDecoder
        |> optional "spaceId" (D.maybe spaceIdDecoder) Nothing
        |> optional "workbookId" (D.maybe D.string) Nothing
        |> optional "sheetId" (D.maybe D.string) Nothing
        |> optional "sheetSlug" (D.maybe D.string) Nothing
        |> optional "versionId" (D.maybe D.string) Nothing
        |> optional "jobId" (D.maybe D.string) Nothing
        |> optional "fileId" (D.maybe D.string) Nothing
        |> optional "procedingEventId" (D.maybe D.string) Nothing


environmentIdDecoder : D.Decoder EnvironmentId.EnvironmentId
environmentIdDecoder =
    D.map EnvironmentId.wrap D.string


spaceIdDecoder : D.Decoder SpaceId.SpaceId
spaceIdDecoder =
    D.map SpaceId.wrap D.string


posixFromIso8601Decoder : D.Decoder Time.Posix
posixFromIso8601Decoder =
    let
        decoder : D.Decoder (String -> Time.Posix)
        decoder =
            D.succeed <|
                (Iso8601.toTime >> Result.withDefault (Time.millisToPosix 0))
    in
    D.andMap D.string decoder



-- flags : D.Decoder Flags
-- flags =
--     D.field "accessToken" (D.maybe D.string)
--         |> D.map Flags


flags : D.Decoder Flags
flags =
    D.field "accessToken" (D.maybe Api.storageDecoder)
        |> D.map Flags
