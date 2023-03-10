module InteropDefinitions exposing
    ( Flags
    , FromElm(..)
    , ToElm(..)
    , interop
    )

import Environment exposing (EnvironmentId(..))
import PubNub
    exposing
        ( Context
        , Domain(..)
        , DomainEvent
        , Topic(..)
        )
import Space exposing (SpaceId(..))
import TsJson.Decode as TsDecode exposing (Decoder)
import TsJson.Decode.Pipeline exposing (optional, required)
import TsJson.Encode as TsEncode exposing (Encoder)


interop :
    { toElm : Decoder ToElm
    , fromElm : Encoder FromElm
    , flags : Decoder Flags
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
        , spaceId : SpaceId
        , subscribeKey : String
        , token : String
        }


type ToElm
    = PNDomainEvent DomainEvent


type alias Flags =
    {}



-- ENCODERS


fromElm : Encoder FromElm
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
                , TsEncode.required "spaceId" .spaceId (TsEncode.map Space.unwrap TsEncode.string)
                , TsEncode.required "subscribeKey" .subscribeKey TsEncode.string
                , TsEncode.required "token" .token TsEncode.string
                ]
            )
        |> TsEncode.buildUnion



-- DECODERS


toElm : Decoder ToElm
toElm =
    TsDecode.map PNDomainEvent domainEventDecoder


domainEventDecoder : Decoder DomainEvent
domainEventDecoder =
    TsDecode.succeed DomainEvent
        |> required "id" TsDecode.string
        |> required "domain" domainDecoder
        |> required "topic" topicDecoder
        |> required "context" contextDecoder
        |> required "payload" TsDecode.value
        |> optional "createdAt" (TsDecode.maybe TsDecode.string) Nothing


domainDecoder : Decoder Domain
domainDecoder =
    TsDecode.stringUnion
        [ ( "file", File )
        , ( "job", Job )
        , ( "space", Space )
        , ( "workbook", Workbook )
        ]


topicDecoder : Decoder Topic
topicDecoder =
    TsDecode.stringUnion
        [ ( "job:completed", JobCompleted )
        , ( "job:deleted", JobDeleted )
        , ( "job:failed", JobFailed )
        , ( "job:started", JobStarted )
        , ( "job:updated", JobUpdated )
        , ( "job:waiting", JobWaiting )
        , ( "records:created", RecordsCreated )
        , ( "records:deleted", RecordsDeleted )
        , ( "records:updated", RecordsUpdated )
        , ( "sheet:validated", SheetValidated )
        , ( "space:added", SpaceAdded )
        , ( "space:removed", SpaceRemoved )
        , ( "upload:completed", UploadCompleted )
        , ( "upload:failed", UploadFailed )
        , ( "upload:started", UploadStarted )
        , ( "user:added", UserAdded )
        , ( "user:offline", UserOffline )
        , ( "user:online", UserOnline )
        , ( "user:removed", UserRemoved )
        , ( "workbook:added", WorkbookAdded )
        , ( "workbook:removed", WorkbookRemoved )
        ]


contextDecoder : Decoder Context
contextDecoder =
    TsDecode.succeed Context
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


environmentIdDecoder : Decoder EnvironmentId
environmentIdDecoder =
    TsDecode.map EnvironmentId TsDecode.string


spaceIdDecoder : Decoder SpaceId
spaceIdDecoder =
    TsDecode.map SpaceId TsDecode.string


flags : Decoder Flags
flags =
    TsDecode.null {}
