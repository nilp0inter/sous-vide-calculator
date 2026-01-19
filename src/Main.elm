module Main exposing (main)

import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class)


main : Html msg
main =
    div [ class "min-h-screen bg-gray-100 flex flex-col items-center justify-center p-4" ]
        [ div [ class "bg-white shadow-lg rounded-lg p-8 max-w-md w-full" ]
            [ h1 [ class "text-3xl font-bold text-gray-800 mb-4 text-center" ] [ text "Sous Vide Calculator" ]
            , div [ class "text-gray-600 text-center" ]
                [ text "Ready for some precision cooking?" ]
            , div [ class "mt-6 p-4 bg-blue-50 rounded border-l-4 border-blue-500 text-blue-700" ]
                [ text "Elm + Tailwind + Vite setup complete!!!" ]
            ]
        ]
