module Environment exposing
    ( Environment
    , EnvironmentId
    , environmentIdDecoder
    , list
    , unwrap
    )

import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import RemoteData exposing (WebData)


type EnvironmentId
    = EnvironmentId String


type alias Environment =
    { id : EnvironmentId
    , accountId : String
    , name : String
    }


unwrap : EnvironmentId -> String
unwrap (EnvironmentId id) =
    id



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
        |> required "id" environmentIdDecoder
        |> required "accountId" Decode.string
        |> required "name" Decode.string


environmentIdDecoder : Decoder EnvironmentId
environmentIdDecoder =
    Decode.map EnvironmentId Decode.string
