module Calculators.ShelfLife exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- MODEL


type alias Model =
    { fridgeTempInput : String
    }


init : Model
init =
    { fridgeTempInput = "4" -- Default 4C or ~39F
    }


type Msg
    = SetFridgeTemp String


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetFridgeTemp val ->
            { model | fridgeTempInput = val }



-- LOGIC


{-| Returns max storage duration in days based on refrigerator temperature in Celsius.
-}
getStorageDuration : Float -> Maybe Int
getStorageDuration tempC =
    if tempC <= 2.5 then
        Just 90
    else if tempC <= 3.3 then
        Just 31
    else if tempC <= 5.0 then
        Just 10
    else if tempC <= 7.0 then
        Just 5
    else
        Nothing


-- VIEW


view : Bool -> Model -> Html Msg
view isMetric model =
    div [ class "max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-sm" ]
        [ h2 [ class "text-2xl font-bold mb-6 text-gray-800 border-b pb-2" ]
            [ text "Shelf-Life & Storage Timer" ]
        
        , div [ class "grid grid-cols-1 md:grid-cols-2 gap-8" ]
            [ -- Input Section
              div [ class "space-y-6" ]
                [ viewFridgeTempInput isMetric model.fridgeTempInput
                ]
            
            -- Result Section
            , div [ class "bg-purple-50 rounded-lg p-6 flex flex-col justify-center items-center text-center" ]
                [ h3 [ class "text-lg font-medium text-purple-800 mb-2" ] [ text "Maximum Storage" ]
                , viewResult isMetric model
                ]
            ]
        ]


viewFridgeTempInput : Bool -> String -> Html Msg
viewFridgeTempInput isMetric valueStr =
    let
        unit = if isMetric then "°C" else "°F"
        placeholderStr = if isMetric then "e.g., 4" else "e.g., 39"
    in
    div []
        [ label [ class "block text-sm font-medium text-gray-700 mb-1" ] [ text ("Current Refrigerator Temperature (" ++ unit ++ ")") ]
        , div [ class "relative rounded-md shadow-sm" ]
            [ input
                [ type_ "number"
                , class "focus:ring-purple-500 focus:border-purple-500 block w-full pr-12 sm:text-sm border-gray-300 rounded-md p-2 border"
                , placeholder placeholderStr
                , value valueStr
                , onInput SetFridgeTemp
                , step "any"
                ]
                []
            , div [ class "absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none" ]
                [ span [ class "text-gray-500 sm:text-sm" ] [ text unit ] ]
            ]
        ]


viewResult : Bool -> Model -> Html Msg
viewResult isMetric model =
    let
        fridgeTemp = String.toFloat model.fridgeTempInput
        
        -- Convert input temp to Celsius for logic
        cTemp =
            fridgeTemp
                |> Maybe.map (\t -> if isMetric then t else (t - 32) * 5 / 9)

        result =
            Maybe.andThen getStorageDuration cTemp
    in
    case (fridgeTemp, result) of
        (Just _, Just days) ->
            div []
                [ span [ class "text-4xl font-extrabold text-purple-900 block" ] [ text (String.fromInt days ++ " days") ]
                , p [ class "text-sm text-purple-600 mt-2" ] [ text "at this temperature." ]
                ]

        (Just _, Nothing) ->
            p [ class "text-red-600 font-medium" ] [ text "Temperature is too high for safe extended storage." ]

        _ ->
            p [ class "text-gray-400 italic" ] [ text "Enter a valid temperature..." ]