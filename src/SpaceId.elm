module SpaceId exposing
    ( SpaceId
    , decoder
    , toString
    , wrap
    )

import Json.Decode as Decode exposing (Decoder)


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



-- DECODERS


decoder : Decoder SpaceId
decoder =
    Decode.map SpaceId Decode.string
