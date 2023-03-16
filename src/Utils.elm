module Utils exposing (mkTestAttribute)

import Html exposing (Attribute)
import Html.Attributes as Attr


mkTestAttribute : String -> Attribute msg
mkTestAttribute =
    Attr.attribute "data-testid" << String.toLower
