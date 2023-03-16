module AgentId exposing
    ( AgentId
    , decoder
    , toString
    )

import Json.Decode as Decode exposing (Decoder)


{-| Opaque type. DO NOT EXPOSE variants!

Flatfile `AgentId` strings will look like `us_ag_ZXghYesD`

-}
type AgentId
    = AgentId String


toString : AgentId -> String
toString (AgentId id) =
    id



-- DECODERS


decoder : Decoder AgentId
decoder =
    Decode.map AgentId Decode.string
