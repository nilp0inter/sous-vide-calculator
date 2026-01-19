module Calculators.Pasteurization exposing (Model, Msg, init, update, view)

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
        [ h2 [ class "text-2xl font-bold mb-4 text-gray-800" ] [ text "Pasteurization (Safety) Calculator" ]
        , p [ class "text-gray-600 mb-4" ]
            [ text "Ensure food reaches required log reduction of pathogens." ]
        , div [ class "bg-red-50 p-4 rounded-md" ]
            [ h3 [ class "font-semibold mb-2" ] [ text "Planned Inputs:" ]
            , ul [ class "list-disc pl-5 space-y-1 text-sm text-gray-700" ]
                [ li [] [ text "Protein Type (Poultry, Meat, Fish)" ]
                , li [] [ text ("Thickness (" ++ (if isMetric then "mm" else "in") ++ ")") ]
                , li [] [ text ("Bath Temperature (" ++ (if isMetric then "°C" else "°F") ++ ")") ]
                , li [] [ text "Safety Buffer Toggle (Acidified Marinades)" ]
                ]
            ]
        ]

h3 : List (Html.Attribute msg) -> List (Html msg) -> Html msg
h3 attributes children =
    Html.h3 attributes children