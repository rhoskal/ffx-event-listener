module EnvironmentId exposing
    ( EnvironmentId
    , decoder
    , toString
    , wrap
    )

import Json.Decode as D


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



-- JSON


decoder : D.Decoder EnvironmentId
decoder =
    D.map EnvironmentId D.string
