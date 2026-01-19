module Calculators.BrineMarinade exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- MODEL


type ProteinType
    = PorkPoultry
    | Brisket


type alias Model =
    { liquidWeightInput : String
    , proteinType : ProteinType
    }


init : Model
init =
    { liquidWeightInput = "1000" -- Default 1000g or ~35oz
    , proteinType = PorkPoultry
    }


type Msg
    = SetLiquidWeight String
    | SetProteinType ProteinType


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetLiquidWeight val ->
            { model | liquidWeightInput = val }

        SetProteinType pType ->
            { model | proteinType = pType }



-- CALCULATIONS


type alias BrineRatios =
    { saltMinRatio : Float
    , saltMaxRatio : Float
    , sugarRatio : Float
    }


getBrineRatios : ProteinType -> BrineRatios
getBrineRatios pType =
    case pType of
        PorkPoultry ->
            { saltMinRatio = 0.05 -- 5%
            , saltMaxRatio = 0.10 -- 10%
            , sugarRatio = 0.0 -- Not specified, assume 0
            }

        Brisket ->
            { saltMinRatio = 0.04 -- 4%
            , saltMaxRatio = 0.04 -- 4%
            , sugarRatio = 0.03 -- 3%
            }


calculateAmounts : Bool -> Model -> Maybe { saltMin : Float, saltMax : Float, sugar : Float }
calculateAmounts isMetric model =
    String.toFloat model.liquidWeightInput
        |> Maybe.map
            (\inputWeight ->
                let
                    -- Convert input to grams for calculation consistency
                    liquidWeightGrams =
                        if isMetric then
                            inputWeight
                        else
                            inputWeight * 28.3495 -- 1 oz = 28.3495 grams

                    ratios =
                        getBrineRatios model.proteinType

                    saltMinGrams =
                        liquidWeightGrams * ratios.saltMinRatio

                    saltMaxGrams =
                        liquidWeightGrams * ratios.saltMaxRatio

                    sugarGrams =
                        liquidWeightGrams * ratios.sugarRatio
                in
                { saltMin =
                    if isMetric then
                        saltMinGrams
                    else
                        saltMinGrams / 28.3495 -- Convert back to ounces
                , saltMax =
                    if isMetric then
                        saltMaxGrams
                    else
                        saltMaxGrams / 28.3495
                , sugar =
                    if isMetric then
                        sugarGrams
                    else
                        sugarGrams / 28.3495
                }
            )



-- VIEW


view : Bool -> Model -> Html Msg
view isMetric model =
    div [ class "max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-sm" ]
        [ h2 [ class "text-2xl font-bold mb-6 text-gray-800 border-b pb-2" ]
            [ text "Brine & Marinade Ratio Tool" ]
        
        , div [ class "grid grid-cols-1 md:grid-cols-2 gap-8" ]
            [ -- Input Section
              div [ class "space-y-6" ]
                [ viewProteinTypeSelector model.proteinType
                , viewLiquidWeightInput isMetric model.liquidWeightInput
                ]
            
            -- Result Section
            , div [ class "bg-yellow-50 rounded-lg p-6 flex flex-col justify-center items-center text-center" ]
                [ h3 [ class "text-lg font-medium text-yellow-800 mb-2" ] [ text "Required Amounts" ]
                , viewResult isMetric model
                ]
            ]
        ]


viewProteinTypeSelector : ProteinType -> Html Msg
viewProteinTypeSelector selected =
    div []
        [ label [ class "block text-sm font-medium text-gray-700 mb-2" ] [ text "Protein Type" ]
        , div [ class "flex rounded-md shadow-sm" ]
            [ proteinTypeButton "Pork / Poultry" PorkPoultry selected "rounded-l-md"
            , proteinTypeButton "Brisket" Brisket selected "rounded-r-md"
            ]
        ]


proteinTypeButton : String -> ProteinType -> ProteinType -> String -> Html Msg
proteinTypeButton labelStr pType selected roundedClass =
    let
        isSelected = pType == selected
        baseClasses = "flex-1 px-4 py-2 text-sm font-medium border focus:z-10 focus:ring-2 focus:ring-yellow-500"
        colors =
            if isSelected then
                "bg-yellow-600 text-white border-yellow-600"
            else
                "bg-white text-gray-700 border-gray-300 hover:bg-gray-50"
    in
    button
        [ type_ "button"
        , class (baseClasses ++ " " ++ colors ++ " " ++ roundedClass)
        , onClick (SetProteinType pType)
        ]
        [ text labelStr ]


viewLiquidWeightInput : Bool -> String -> Html Msg
viewLiquidWeightInput isMetric valueStr =
    let
        unit = if isMetric then "g" else "oz"
        placeholderStr = if isMetric then "e.g., 1000" else "e.g., 35.27"
    in
    div []
        [ label [ class "block text-sm font-medium text-gray-700 mb-1" ] [ text ("Weight of Water/Liquid (" ++ unit ++ ")") ]
        , div [ class "relative rounded-md shadow-sm" ]
            [ input
                [ type_ "number"
                , class "focus:ring-yellow-500 focus:border-yellow-500 block w-full pr-12 sm:text-sm border-gray-300 rounded-md p-2 border"
                , placeholder placeholderStr
                , value valueStr
                , onInput SetLiquidWeight
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
        unit = if isMetric then "g" else "oz"
        
        round2dp : Float -> Float
        round2dp number =
            let
                multiplier = 100.0
                rounded = round (number * multiplier)
            in
            toFloat rounded / multiplier

        format f = String.fromFloat (round2dp f)
    in
    case calculateAmounts isMetric model of
        Just { saltMin, saltMax, sugar } ->
            div [ class "space-y-3" ]
                [ if model.proteinType == PorkPoultry then
                    p [ class "text-gray-900" ]
                        [ span [ class "font-bold" ] [ text "Salt: " ]
                        , text (format saltMin ++ unit ++ " to " ++ format saltMax ++ unit)
                        ]
                  else
                    p [ class "text-gray-900" ]
                        [ span [ class "font-bold" ] [ text "Salt: " ]
                        , text (format saltMin ++ unit)
                        ]
                , if sugar > 0 then
                    p [ class "text-gray-900" ]
                        [ span [ class "font-bold" ] [ text "Sugar: " ]
                        , text (format sugar ++ unit)
                        ]
                  else
                    text ""
                ]

        Nothing ->
            p [ class "text-gray-400 italic" ] [ text "Enter a valid liquid weight..." ]