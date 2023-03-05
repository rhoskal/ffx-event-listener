module InteropDefinitions exposing
    ( Flags
    , FromElm(..)
    , ToElm(..)
    , interop
    )

import TsJson.Decode as TsDecode exposing (Decoder)
import TsJson.Decode.Pipeline exposing (required)
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
    = OpenExternalLink String


type ToElm
    = PNWorkbookEvent WorkbookEvent
    | PNFileEvent FileEvent
    | PNJobEvent JobEvent
    | PNSpaceEvent SpaceEvent


type alias WorkbookEvent =
    { id : String
    , createdAt : String
    }


type alias FileEvent =
    { id : String
    , createdAt : String
    }


type alias JobEvent =
    { id : String
    , createdAt : String
    }


type alias SpaceEvent =
    { id : String
    , createdAt : String
    }


type alias Flags =
    {}



-- ENCODERS


fromElm : Encoder FromElm
fromElm =
    TsEncode.union
        (\vExternalLink value ->
            case value of
                OpenExternalLink string ->
                    vExternalLink string
        )
        |> TsEncode.variantTagged "openExternalLink"
            (TsEncode.object [ TsEncode.required "url" identity TsEncode.string ])
        |> TsEncode.buildUnion



-- DECODERS


toElm : Decoder ToElm
toElm =
    TsDecode.discriminatedUnion "domain"
        [ ( "workbook", TsDecode.map PNWorkbookEvent workbookEventDecoder )
        , ( "file", TsDecode.map PNFileEvent fileEventDecoder )
        , ( "job", TsDecode.map PNJobEvent jobEventDecoder )
        , ( "space", TsDecode.map PNSpaceEvent spaceEventDecoder )
        ]


workbookEventDecoder : Decoder WorkbookEvent
workbookEventDecoder =
    TsDecode.succeed WorkbookEvent
        |> required "id" TsDecode.string
        |> required "createdAt" TsDecode.string


fileEventDecoder : Decoder FileEvent
fileEventDecoder =
    TsDecode.succeed FileEvent
        |> required "id" TsDecode.string
        |> required "createdAt" TsDecode.string


jobEventDecoder : Decoder JobEvent
jobEventDecoder =
    TsDecode.succeed JobEvent
        |> required "id" TsDecode.string
        |> required "createdAt" TsDecode.string


spaceEventDecoder : Decoder SpaceEvent
spaceEventDecoder =
    TsDecode.succeed SpaceEvent
        |> required "id" TsDecode.string
        |> required "createdAt" TsDecode.string


flags : Decoder Flags
flags =
    TsDecode.null {}
