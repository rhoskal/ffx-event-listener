module SpaceId exposing
    ( SpaceId
    , decoder
    , toString
    , wrap
    )

import Json.Decode as D


{-| Opaque type. DO NOT EXPOSE variants!

Flatfile `SpaceId` strings will look like `us_sp_ZXghYesD`

-}
type SpaceId
    = SpaceId String


toString : SpaceId -> String
toString (SpaceId id) =
    id


wrap : String -> SpaceId
wrap =
    SpaceId



-- JSON


decoder : D.Decoder SpaceId
decoder =
    D.map SpaceId D.string
