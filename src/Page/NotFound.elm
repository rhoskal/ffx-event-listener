module Page.NotFound exposing (view)

import Html exposing (..)
import Html.Attributes as Attr



-- VIEW


view : { title : String, content : Html msg }
view =
    { title = "Page Not Found"
    , content =
        main_ [ Attr.class "", Attr.tabindex -1 ]
            [ div [] [ text "Page Not Found" ]
            ]
    }
