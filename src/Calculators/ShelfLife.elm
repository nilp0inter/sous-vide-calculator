module Calculators.ShelfLife exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Slider
import Round


-- MODEL


type alias Model =
    { fridgeTempInput : Float
    }


init : Model
init =
    { fridgeTempInput = 4.0
    }


type Msg
    = SetFridgeTemp Float


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


view : Model -> Html Msg
view model =
    div [ class "max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-sm" ]
        [ h2 [ class "text-2xl font-bold mb-6 text-gray-800 border-b pb-2" ]
            [ text "Shelf-Life & Storage Timer" ]
        
        , div [ class "grid grid-cols-1 md:grid-cols-2 gap-8" ]
            [ -- Input Section
              div [ class "space-y-6" ]
                [ viewFridgeTempSlider model
                ]
            
            -- Result Section
            , div [ class "bg-purple-50 rounded-lg p-6 flex flex-col justify-center items-center text-center" ]
                [ h3 [ class "text-lg font-medium text-purple-800 mb-2" ] [ text "Maximum Storage" ]
                , viewResult model
                ]
            ]
        ]


viewFridgeTempSlider : Model -> Html Msg
viewFridgeTempSlider model =
    let
        -- Valid steps including the critical thresholds
        allowed = [0, 1, 2, 2.5, 3, 3.3, 4, 5, 6, 7]
        
        formatter val =
            let
                c = String.fromFloat val ++ " °C"
                f = Round.round 1 ((val * 9/5) + 32) ++ " °F"
            in
            c ++ " / " ++ f
    in
    Slider.view
        { value = model.fridgeTempInput
        , allowedValues = allowed
        , toMsg = SetFridgeTemp
        , label = "Refrigerator Temperature"
        , formatter = formatter
        }


viewResult : Model -> Html Msg
viewResult model =
    let
        result =
            getStorageDuration model.fridgeTempInput
    in
    case result of
        Just days ->
            div []
                [ span [ class "text-4xl font-extrabold text-purple-900 block" ] [ text (String.fromInt days ++ " days") ]
                , p [ class "text-sm text-purple-600 mt-2" ] [ text "at this temperature." ]
                ]

        Nothing ->
            p [ class "text-red-600 font-medium" ] [ text "Temperature is too high for safe extended storage." ]