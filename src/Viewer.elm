module Viewer exposing (Viewer, cred, wrap)

{-| The logged-in user currently viewing this page. It stores enough data e.g.
the Cred so it's impossible to have a Viewer if you aren't logged in.
-}

import Api


type Viewer
    = Viewer Api.Cred


cred : Viewer -> Api.Cred
cred (Viewer val) =
    val


wrap : Api.Cred -> Viewer
wrap =
    Viewer
