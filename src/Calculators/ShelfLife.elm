module Calculators.ShelfLife exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Slider
import Round
import Data exposing (ShelfLifeRule)


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
getStorageDuration : List ShelfLifeRule -> Float -> Maybe Int
getStorageDuration rules tempC =
    -- Rules are sorted by maxTemp in JSON presumably, but we should find the first rule where tempC <= maxTemp
    rules
        |> List.filter (\rule -> tempC <= rule.maxTemp)
        |> List.sortBy .maxTemp
        |> List.head
        |> Maybe.map .days


-- VIEW


view : List ShelfLifeRule -> Model -> Html Msg
view rules model =
    div [ class "max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-sm" ]
        [ h2 [ class "text-2xl font-bold mb-6 text-gray-800 border-b pb-2" ]
            [ text "Shelf-Life & Storage Timer" ]
        
        , div [ class "grid grid-cols-1 md:grid-cols-2 gap-8" ]
            [ -- Input Section
              div [ class "space-y-6" ]
                [ viewFridgeTempSlider rules model
                ]
            
            -- Result Section
            , div [ class "bg-purple-50 rounded-lg p-6 flex flex-col justify-center items-center text-center" ]
                [ h3 [ class "text-lg font-medium text-purple-800 mb-2" ] [ text "Maximum Storage" ]
                , viewResult rules model
                ]
            ]
        ]


viewFridgeTempSlider : List ShelfLifeRule -> Model -> Html Msg
viewFridgeTempSlider rules model =
    let
        -- Extract thresholds from rules and add some intermediate steps if needed
        -- Or just use the thresholds as the snap points + 0.
        thresholds = List.map .maxTemp rules
        
        -- Add 0, 1, 2, 3, 4, 5, 6, 7 if not present?
        -- The previous allowed was [0, 1, 2, 2.5, 3, 3.3, 4, 5, 6, 7]
        -- Let's reconstruct a useful range.
        -- We can just take the rule thresholds and maybe some integers.
        -- Let's stick to the rule thresholds + 0 + integers up to max threshold.
        
        maxT = List.maximum thresholds |> Maybe.withDefault 7
        
        integers = List.range 0 (round maxT) |> List.map toFloat
        
        allowed = (integers ++ thresholds) |> List.sort |> unique
        
        unique list =
            List.foldr (\x acc -> if List.member x acc then acc else x :: acc) [] list

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


viewResult : List ShelfLifeRule -> Model -> Html Msg
viewResult rules model =
    let
        result =
            getStorageDuration rules model.fridgeTempInput
    in
    case result of
        Just days ->
            div []
                [ span [ class "text-4xl font-extrabold text-purple-900 block" ] [ text (String.fromInt days ++ " days") ]
                , p [ class "text-sm text-purple-600 mt-2" ] [ text "at this temperature." ]
                ]

        Nothing ->
            p [ class "text-red-600 font-medium" ] [ text "Temperature is too high for safe extended storage." ]