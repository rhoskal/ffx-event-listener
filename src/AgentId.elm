module AgentId exposing
    ( AgentId
    , decoder
    , toString
    )

import Json.Decode as D


{-| Opaque type. DO NOT EXPOSE variants!

Flatfile `AgentId` strings will look like `us_ag_ZXghYesD`

-}
type AgentId
    = AgentId String


toString : AgentId -> String
toString (AgentId id) =
    id



-- JSON


decoder : D.Decoder AgentId
decoder =
    D.map AgentId D.string
