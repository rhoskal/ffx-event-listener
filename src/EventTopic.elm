module EventTopic exposing
    ( EventTopic(..)
    , decoder
    , toHtml
    )

import Html exposing (span, text)
import Html.Attributes as Attr
import Json.Decode as D


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



-- JSON


decoder : D.Decoder EventTopic
decoder =
    D.string
        |> D.andThen
            (\topic ->
                case topic of
                    "action:triggered" ->
                        D.succeed ActionTriggered

                    "job:completed" ->
                        D.succeed JobCompleted

                    "job:deleted" ->
                        D.succeed JobDeleted

                    "job:failed" ->
                        D.succeed JobFailed

                    "job:started" ->
                        D.succeed JobStarted

                    "job:updated" ->
                        D.succeed JobUpdated

                    "job:waiting" ->
                        D.succeed JobWaiting

                    "records:created" ->
                        D.succeed RecordsCreated

                    "records:deleted" ->
                        D.succeed RecordsDeleted

                    "records:updated" ->
                        D.succeed RecordsUpdated

                    "sheet:validated" ->
                        D.succeed SheetValidated

                    "space:added" ->
                        D.succeed SpaceAdded

                    "space:removed" ->
                        D.succeed SpaceRemoved

                    "upload:completed" ->
                        D.succeed UploadCompleted

                    "upload:failed" ->
                        D.succeed UploadFailed

                    "upload:started" ->
                        D.succeed UploadStarted

                    "user:added" ->
                        D.succeed UserAdded

                    "user:offline" ->
                        D.succeed UserOffline

                    "user:online" ->
                        D.succeed UserOnline

                    "user:removed" ->
                        D.succeed UserRemoved

                    "workbook:added" ->
                        D.succeed WorkbookAdded

                    "workbook:removed" ->
                        D.succeed WorkbookRemoved

                    _ ->
                        D.fail ("Unknown event topic encountered: " ++ topic)
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


toHtml : EventTopic -> Html.Html msg
toHtml eventTopic =
    span [ Attr.class "inline-flex items-center rounded-md bg-gray-100 px-2.5 py-0.5 text-sm font-medium text-gray-800 select-none" ]
        [ text <| toString eventTopic ]
