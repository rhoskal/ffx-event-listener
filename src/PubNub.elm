module PubNub exposing (SubscriptionCreds, auth)

import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import RemoteData exposing (WebData)
import Space exposing (SpaceId)


type alias SubscriptionCreds =
    { accountId : String
    , subscribeKey : String
    , token : String
    }



-- HTTP


auth : SpaceId -> Maybe Cred -> (WebData SubscriptionCreds -> msg) -> Cmd msg
auth spaceId maybeCred toMsg =
    Api.get (Endpoint.pubNubAuth <| Space.unwrap spaceId) maybeCred toMsg subscriptionCredsDecoder



-- DECODERS


subscriptionCredsDecoder : Decoder SubscriptionCreds
subscriptionCredsDecoder =
    let
        decoder : Decoder SubscriptionCreds
        decoder =
            Decode.succeed SubscriptionCreds
                |> required "accountId" Decode.string
                |> required "subscribeKey" Decode.string
                |> required "token" Decode.string
    in
    Decode.at [ "data" ] decoder
