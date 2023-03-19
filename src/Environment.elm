module Environment exposing
    ( Environment
    , decoder
    , list
    )

import Api
import Api.Endpoint as Endpoint
import EnvironmentId
import Json.Decode as D
import Json.Decode.Pipeline exposing (required)
import RemoteData as RD


type alias Environment =
    { id : EnvironmentId.EnvironmentId
    , accountId : String
    , name : String
    }



-- HTTP


list :
    Maybe Api.Cred
    -> (RD.WebData (List Environment) -> msg)
    -> Cmd msg
list maybeCred toMsg =
    Api.get Endpoint.listEnvironments maybeCred toMsg listDecoder



-- JSON


listDecoder : D.Decoder (List Environment)
listDecoder =
    D.at [ "data" ] (D.list decoder)


decoder : D.Decoder Environment
decoder =
    D.succeed Environment
        |> required "id" EnvironmentId.decoder
        |> required "accountId" D.string
        |> required "name" D.string
