module Calculators.Doneness exposing (Model, Msg, init, update, view)

import Html exposing (Html, div, h2, p, ul, li, text)
import Html.Attributes exposing (class)


type alias Model =
    {}


init : Model
init =
    {}


type Msg
    = NoOp


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model


view : Bool -> Model -> Html Msg
view isMetric model =
    div [ class "p-6 bg-white rounded-lg shadow" ]
        [ h2 [ class "text-2xl font-bold mb-4 text-gray-800" ] [ text "Doneness & Texture Visualizer" ]
        , p [ class "text-gray-600 mb-4" ]
            [ text "Choose your temperature based on the desired final texture." ]
        , div [ class "bg-yellow-50 p-4 rounded-md" ]
            [ h3 [ class "font-semibold mb-2" ] [ text "Planned Inputs:" ]
            , ul [ class "list-disc pl-5 space-y-1 text-sm text-gray-700" ]
                [ li [] [ text "Protein Type (Beef, Pork, Fish, etc.)" ]
                ]
            ]
        ]

h3 : List (Html.Attribute msg) -> List (Html msg) -> Html msg
h3 attributes children =
    Html.h3 attributes children
