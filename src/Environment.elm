module Environment exposing
    ( Environment
    , environmentDecoder
    , list
    )

import Api exposing (Cred)
import Api.Endpoint as Endpoint
import EnvironmentId exposing (EnvironmentId)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import RemoteData exposing (WebData)


type alias Environment =
    { id : EnvironmentId
    , accountId : String
    , name : String
    }



-- HTTP


list : Maybe Cred -> (WebData (List Environment) -> msg) -> Cmd msg
list maybeCred toMsg =
    Api.get Endpoint.listEnvironments maybeCred toMsg environmentsDecoder



-- DECODERS


environmentsDecoder : Decoder (List Environment)
environmentsDecoder =
    Decode.at [ "data" ] (Decode.list environmentDecoder)


environmentDecoder : Decoder Environment
environmentDecoder =
    Decode.succeed Environment
        |> required "id" EnvironmentId.decoder
        |> required "accountId" Decode.string
        |> required "name" Decode.string
