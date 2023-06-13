module EventTopic exposing
    ( EventTopic(..)
    , decoder
    , toHtml
    )

import Html exposing (span, text)
import Html.Attributes as Attr
import Json.Decode as D


type EventTopic
    = AgentCreated
    | AgentDeleted
    | AgentUpdated
    | CommitCreated
    | CommitUpdated
    | DocumentCreated
    | DocumentDeleted
    | DocumentUpdated
    | FileCreated
    | FileDeleted
    | FileUpdated
    | JobCompleted
    | JobCreated
    | JobDeleted
    | JobFailed
    | JobOutcomeAck
    | JobReady
    | JobScheduled
    | JobUpdated
    | LayerCreated
    | RecordCreated
    | RecordDeleted
    | RecordUpdated
    | SheetCreated
    | SheetDeleted
    | SheetUpdated
    | SpaceCreated
    | SpaceDeleted
    | SpaceUpdated
    | WorkbookCreated
    | WorkbookDeleted
    | WorkbookUpdated


decoder : D.Decoder EventTopic
decoder =
    D.string
        |> D.andThen
            (\topic ->
                case topic of
                    "agent:created" ->
                        D.succeed AgentCreated

                    "agent:deleted" ->
                        D.succeed AgentDeleted

                    "agent:updated" ->
                        D.succeed AgentUpdated

                    "commit:created" ->
                        D.succeed CommitCreated

                    "commit:updated" ->
                        D.succeed CommitUpdated

                    "document:created" ->
                        D.succeed DocumentCreated

                    "document:deleted" ->
                        D.succeed DocumentDeleted

                    "document:updated" ->
                        D.succeed DocumentUpdated

                    "file:created" ->
                        D.succeed FileCreated

                    "file:deleted" ->
                        D.succeed FileDeleted

                    "file:updated" ->
                        D.succeed FileUpdated

                    "job:completed" ->
                        D.succeed JobCompleted

                    "job:created" ->
                        D.succeed JobCreated

                    "job:deleted" ->
                        D.succeed JobDeleted

                    "job:failed" ->
                        D.succeed JobFailed

                    "job:outcome:outcome-acknowledged" ->
                        D.succeed JobOutcomeAck

                    "job:ready" ->
                        D.succeed JobReady

                    "job:scheduled" ->
                        D.succeed JobScheduled

                    "job:updated" ->
                        D.succeed JobUpdated

                    "layer:created" ->
                        D.succeed LayerCreated

                    "record:created" ->
                        D.succeed RecordCreated

                    "record:deleted" ->
                        D.succeed RecordDeleted

                    "record:updated" ->
                        D.succeed RecordUpdated

                    "sheet:created" ->
                        D.succeed SheetCreated

                    "sheet:deleted" ->
                        D.succeed SheetDeleted

                    "sheet:updated" ->
                        D.succeed SheetUpdated

                    "space:created" ->
                        D.succeed SpaceCreated

                    "space:deleted" ->
                        D.succeed SpaceDeleted

                    "space:updated" ->
                        D.succeed SpaceUpdated

                    "workbook:created" ->
                        D.succeed WorkbookCreated

                    "workbook:deleted" ->
                        D.succeed WorkbookDeleted

                    "workbook:updated" ->
                        D.succeed WorkbookUpdated

                    _ ->
                        D.fail ("Unknown event topic encountered: " ++ topic)
            )



-- HELPERS


toString : EventTopic -> String
toString topic =
    case topic of
        AgentCreated ->
            "agent:created"

        AgentDeleted ->
            "agent:deleted"

        AgentUpdated ->
            "agent:updated"

        CommitCreated ->
            "commit:created"

        CommitUpdated ->
            "commit:updated"

        DocumentCreated ->
            "document:created"

        DocumentDeleted ->
            "document:deleted"

        DocumentUpdated ->
            "document:updated"

        FileCreated ->
            "file:created"

        FileDeleted ->
            "file:deleted"

        FileUpdated ->
            "file:updated"

        JobCompleted ->
            "job:completed"

        JobCreated ->
            "job:created"

        JobDeleted ->
            "job:deleted"

        JobFailed ->
            "job:failed"

        JobOutcomeAck ->
            "job:outcome-acknowledged"

        JobReady ->
            "job:ready"

        JobScheduled ->
            "job:scheduled"

        JobUpdated ->
            "job:updated"

        LayerCreated ->
            "layer:created"

        RecordCreated ->
            "record:created"

        RecordDeleted ->
            "record:deleted"

        RecordUpdated ->
            "record:updated"

        SheetCreated ->
            "sheet:created"

        SheetDeleted ->
            "sheet:deleted"

        SheetUpdated ->
            "sheet:updated"

        SpaceCreated ->
            "space:created"

        SpaceDeleted ->
            "space:deleted"

        SpaceUpdated ->
            "space:updated"

        WorkbookCreated ->
            "workbook:created"

        WorkbookDeleted ->
            "workbook:deleted"

        WorkbookUpdated ->
            "workbook:updated"


toHtml : EventTopic -> Html.Html msg
toHtml eventTopic =
    span [ Attr.class "inline-flex items-center rounded-md bg-gray-100 px-2.5 py-0.5 text-sm font-medium text-gray-800 select-none" ]
        [ text <| toString eventTopic ]
