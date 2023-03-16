module EventTopic exposing
    ( EventTopic(..)
    , decoder
    , toHtml
    )

import Html exposing (Html, span, text)
import Html.Attributes as Attr
import Json.Decode as Decode exposing (Decoder)


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



-- DECODERS


decoder : Decoder EventTopic
decoder =
    Decode.string
        |> Decode.andThen
            (\topic ->
                case topic of
                    "action:triggered" ->
                        Decode.succeed ActionTriggered

                    "job:completed" ->
                        Decode.succeed JobCompleted

                    "job:deleted" ->
                        Decode.succeed JobDeleted

                    "job:failed" ->
                        Decode.succeed JobFailed

                    "job:started" ->
                        Decode.succeed JobStarted

                    "job:updated" ->
                        Decode.succeed JobUpdated

                    "job:waiting" ->
                        Decode.succeed JobWaiting

                    "records:created" ->
                        Decode.succeed RecordsCreated

                    "records:deleted" ->
                        Decode.succeed RecordsDeleted

                    "records:updated" ->
                        Decode.succeed RecordsUpdated

                    "sheet:validated" ->
                        Decode.succeed SheetValidated

                    "space:added" ->
                        Decode.succeed SpaceAdded

                    "space:removed" ->
                        Decode.succeed SpaceRemoved

                    "upload:completed" ->
                        Decode.succeed UploadCompleted

                    "upload:failed" ->
                        Decode.succeed UploadFailed

                    "upload:started" ->
                        Decode.succeed UploadStarted

                    "user:added" ->
                        Decode.succeed UserAdded

                    "user:offline" ->
                        Decode.succeed UserOffline

                    "user:online" ->
                        Decode.succeed UserOnline

                    "user:removed" ->
                        Decode.succeed UserRemoved

                    "workbook:added" ->
                        Decode.succeed WorkbookAdded

                    "workbook:removed" ->
                        Decode.succeed WorkbookRemoved

                    _ ->
                        Decode.fail ("Unknown event topic encountered: " ++ topic)
            )



-- HELPERS


toString : EventTopic -> String
toString topic =
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


toHtml : EventTopic -> Html msg
toHtml eventTopic =
    span [ Attr.class "inline-flex items-center rounded-md bg-gray-100 px-2.5 py-0.5 text-sm font-medium text-gray-800 select-none" ]
        [ text <| toString eventTopic ]
