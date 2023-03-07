module Environment exposing
    ( Environment
    , EnvironmentId
    , environmentIdDecoder
    , list
    , unwrap
    )

import Api
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



-- FETCH


list : (WebData (List Environment) -> msg) -> Cmd msg
list toMsg =
    Api.get Endpoint.listEnvironments toMsg environmentsDecoder



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
