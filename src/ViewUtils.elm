module ViewUtils exposing (parseBody)

import Html exposing (..)
import Html.Attributes exposing (..)


parseBody : String -> List (Html msg)
parseBody body =
    case String.indices "[" body of
        [] ->
            [ text body ]

        firstIndex :: _ ->
            let
                before =
                    String.left firstIndex body

                remaining =
                    String.dropLeft (firstIndex + 1) body
            in
            case String.indices "]" remaining of
                [] ->
                    [ text body ]

                closeIndex :: _ ->
                    let
                        linkContent =
                            String.left closeIndex remaining

                        after =
                            String.dropLeft (closeIndex + 1) remaining
                    in
                    text before :: renderLink linkContent :: parseBody after


renderLink : String -> Html msg
renderLink content =
    case String.split "|" content of
        [ key, label ] ->
            if String.startsWith "http" key then
                a [ href key, target "_blank", rel "noopener noreferrer", class "text-blue-600 hover:text-blue-800 underline font-medium" ]
                    [ text label ]

            else
                a [ href ("#" ++ key), class "text-blue-600 hover:text-blue-800 underline font-medium" ]
                    [ text label ]

        _ ->
            text ("[" ++ content ++ "]")
