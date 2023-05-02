module EventDomain exposing
    ( EventDomain(..)
    , toHtml
    )

import Html exposing (span, text)
import Html.Attributes as Attr


type EventDomain
    = FileDomain
    | JobDomain
    | SpaceDomain
    | WorkbookDomain


toString : EventDomain -> String
toString domain =
    case domain of
        FileDomain ->
            "File"

        JobDomain ->
            "Job"

        SpaceDomain ->
            "Space"

        WorkbookDomain ->
            "Workbook"


toHtml : EventDomain -> Html.Html msg
toHtml eventDomain =
    case eventDomain of
        FileDomain ->
            span [ Attr.class "inline-flex items-center rounded-md bg-sky-200 px-2.5 py-0.5 text-sm font-medium text-sky-500 select-none" ]
                [ text <| toString eventDomain ]

        JobDomain ->
            span [ Attr.class "inline-flex items-center rounded-md bg-purple-200 px-2.5 py-0.5 text-sm font-medium text-purple-500 select-none" ]
                [ text <| toString eventDomain ]

        SpaceDomain ->
            span [ Attr.class "inline-flex items-center rounded-md bg-green-200 px-2.5 py-0.5 text-sm font-medium text-green-500 select-none" ]
                [ text <| toString eventDomain ]

        WorkbookDomain ->
            span [ Attr.class "inline-flex items-center rounded-md bg-fuchsia-200 px-2.5 py-0.5 text-sm font-medium text-fuchsia-500 select-none" ]
                [ text <| toString eventDomain ]
