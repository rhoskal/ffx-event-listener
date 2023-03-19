module EventId exposing
    ( EventId
    , decoder
    , toString
    , wrap
    )

import Json.Decode as D


{-| Opaque type. DO NOT EXPOSE variants!

Flatfile `EventId` strings will look like `us_evt_ZXghYesDABasderr`

-}
type EventId
    = EventId String


toString : EventId -> String
toString (EventId id) =
    id


wrap : String -> EventId
wrap =
    EventId



-- JSON


decoder : D.Decoder EventId
decoder =
    D.map EventId D.string
