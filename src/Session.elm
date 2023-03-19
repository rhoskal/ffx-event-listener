module Session exposing
    ( Session
    , cred
    , fromViewer
    , navKey
    , viewer
    )

import Api
import Browser.Navigation as Nav
import Viewer


type Session
    = LoggedIn Nav.Key Viewer.Viewer
    | Guest Nav.Key


viewer : Session -> Maybe Viewer.Viewer
viewer session =
    case session of
        LoggedIn _ val ->
            Just val

        Guest _ ->
            Nothing


cred : Session -> Maybe Api.Cred
cred session =
    case session of
        LoggedIn _ val ->
            Just (Viewer.cred val)

        Guest _ ->
            Nothing


navKey : Session -> Nav.Key
navKey session =
    case session of
        LoggedIn key _ ->
            key

        Guest key ->
            key


fromViewer : Nav.Key -> Maybe Viewer.Viewer -> Session
fromViewer navKey_ maybeViewer =
    case maybeViewer of
        Just viewer_ ->
            LoggedIn navKey_ viewer_

        Nothing ->
            Guest navKey_



-- SUBSCRIPTIONS


changes : (Session -> msg) -> Nav.Key -> Sub msg
changes toMsg key =
    Api.viewerChanges (\maybeViewer -> toMsg (fromViewer key maybeViewer)) Viewer.decoder
