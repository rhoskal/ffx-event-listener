module ReviewConfig exposing (config)

import NoInconsistentAliases
import NoUnused.Dependencies
import NoUnused.Exports
import NoUnused.Parameters
import NoUnused.Patterns
import NoUnused.Variables
import Review.Rule exposing (Rule)


config : List Rule
config =
    [ NoInconsistentAliases.config
        [ ( "Html.Attributes", "Attr" )
        , ( "Html.Events", "Events" )
        , ( "Json.Decode", "D" )
        , ( "Json.Encode", "E" )
        , ( "RemoteData", "RD" )
        ]
        |> NoInconsistentAliases.noMissingAliases
        |> NoInconsistentAliases.rule
    , NoUnused.Exports.rule
    , NoUnused.Dependencies.rule
    , NoUnused.Parameters.rule
    , NoUnused.Patterns.rule
    , NoUnused.Variables.rule
    ]
