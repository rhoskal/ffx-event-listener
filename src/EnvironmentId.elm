module EnvironmentId exposing
    ( EnvironmentId
    , decoder
    , toString
    , wrap
    )

import Json.Decode as Decode exposing (Decoder)


{-| Opaque type. DO NOT EXPOSE variants!

Flatfile `EnvironmentId` strings will look like `us_env_ZXghYesD`

-}
type EnvironmentId
    = EnvironmentId String


toString : EnvironmentId -> String
toString (EnvironmentId id) =
    id


wrap : String -> EnvironmentId
wrap =
    EnvironmentId



-- DECODERS


decoder : Decoder EnvironmentId
decoder =
    Decode.map EnvironmentId Decode.string
