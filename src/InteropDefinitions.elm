module InteropDefinitions exposing
    ( Flags
    , FromElm(..)
    , ToElm(..)
    , interop
    )

import TsJson.Decode as TsDecode exposing (Decoder)
import TsJson.Encode as TsEncode exposing (Encoder)


interop :
    { toElm : Decoder ToElm
    , fromElm : Encoder FromElm
    , flags : Decoder Flags
    }
interop =
    { toElm = toElm
    , fromElm = fromElm
    , flags = flags
    }


type FromElm
    = NoOpFrom


type ToElm
    = NoOpTo


type alias Flags =
    {}



-- ENCODERS


fromElm : Encoder FromElm
fromElm =
    TsEncode.null



-- DECODERS


toElm : Decoder ToElm
toElm =
    TsDecode.null NoOpTo


flags : Decoder Flags
flags =
    TsDecode.null {}
