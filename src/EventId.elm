module EventId exposing
    ( EventId
    , decoder
    , toString
    , wrap
    )

import Json.Decode as Decode exposing (Decoder)


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



-- DECODERS


decoder : Decoder EventId
decoder =
    Decode.map EventId Decode.string
