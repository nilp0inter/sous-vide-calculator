module Calculators.BrineMarinade exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Round
import Data exposing (BrineData, BrineRatios)
import Translations exposing (BrineStrings)


-- MODEL


type ProteinType
    = PorkPoultry
    | Brisket

type UnitSystem
    = Metric
    | Imperial

type alias Model =
    { liquidWeightInput : String
    , proteinType : ProteinType
    , units : UnitSystem
    }


init : Model
init =
    { liquidWeightInput = "1000" -- Default 1000g or ~35oz
    , proteinType = PorkPoultry
    , units = Metric
    }


type Msg
    = SetLiquidWeight String
    | SetProteinType ProteinType
    | SetUnits UnitSystem


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetLiquidWeight val ->
            { model | liquidWeightInput = val }

        SetProteinType pType ->
            { model | proteinType = pType }

        SetUnits newUnits ->
            let
                convertedInput =
                    if newUnits == model.units then
                        model.liquidWeightInput
                    else
                        case String.toFloat model.liquidWeightInput of
                            Just val ->
                                case ( model.units, newUnits ) of
                                    ( Metric, Imperial ) ->
                                        -- g -> oz
                                        Round.round 2 (val / 28.3495)

                                    ( Imperial, Metric ) ->
                                        -- oz -> g
                                        Round.round 2 (val * 28.3495)

                                    _ ->
                                        model.liquidWeightInput

                            Nothing ->
                                model.liquidWeightInput
            in
            { model | units = newUnits, liquidWeightInput = convertedInput }



-- CALCULATIONS


getBrineRatios : BrineData -> ProteinType -> BrineRatios
getBrineRatios data pType =
    case pType of
        PorkPoultry -> data.porkPoultry
        Brisket -> data.brisket


calculateAmounts : BrineData -> Model -> Maybe { saltMin : Float, saltMax : Float, sugar : Float, waterGrams : Float }
calculateAmounts data model =
    String.toFloat model.liquidWeightInput
        |> Maybe.map
            (\inputWeight ->
                let
                    isMetric = model.units == Metric
                    
                    -- Convert input to grams for calculation consistency
                    liquidWeightGrams =
                        if isMetric then
                            inputWeight
                        else
                            inputWeight * 28.3495 -- 1 oz = 28.3495 grams

                    ratios =
                        getBrineRatios data model.proteinType

                    saltMinGrams =
                        liquidWeightGrams * ratios.saltMin

                    saltMaxGrams =
                        liquidWeightGrams * ratios.saltMax

                    sugarGrams =
                        liquidWeightGrams * ratios.sugar
                in
                { saltMin = saltMinGrams
                , saltMax = saltMaxGrams
                , sugar = sugarGrams
                , waterGrams = liquidWeightGrams
                }
            )



-- VIEW


view : BrineData -> BrineStrings -> Model -> Html Msg
view data t model =
    div [ class "max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-sm" ]
        [ h2 [ class "text-2xl font-bold mb-6 text-gray-800 border-b pb-2" ]
            [ text t.title ]
        , p [ class "text-gray-600 mb-6 italic" ] [ text t.explanation ]
        
        , div [ class "grid grid-cols-1 md:grid-cols-2 gap-8" ]
            [ -- Input Section
              div [ class "space-y-6" ]
                [ viewProteinTypeSelector t model.proteinType
                , viewUnitSelector t model.units
                , viewLiquidWeightInput t model
                ]
            
            -- Result Section
            , div [ class "bg-yellow-50 rounded-lg p-6 flex flex-col justify-center items-center text-center", attribute "aria-live" "polite" ]
                [ h3 [ class "text-lg font-medium text-yellow-800 mb-2" ] [ text t.resultHeader ]
                , viewResult t data model
                ]
            ]
        ]


viewProteinTypeSelector : BrineStrings -> ProteinType -> Html Msg
viewProteinTypeSelector t selected =
    div [ attribute "role" "radiogroup", attribute "aria-labelledby" "protein-type-label" ]
        [ label [ id "protein-type-label", class "block text-sm font-medium text-gray-700 mb-2" ] [ text t.protein ]
        , div [ class "flex rounded-md shadow-sm" ]
            [ proteinTypeButton t.porkPoultry PorkPoultry selected "rounded-l-md"
            , proteinTypeButton t.brisket Brisket selected "rounded-r-md"
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
        , attribute "role" "radio"
        , attribute "aria-checked" (if isSelected then "true" else "false")
        ]
        [ text labelStr ]


viewUnitSelector : BrineStrings -> UnitSystem -> Html Msg
viewUnitSelector t selected =
    div [ attribute "role" "radiogroup", attribute "aria-labelledby" "unit-label" ]
        [ label [ id "unit-label", class "block text-sm font-medium text-gray-700 mb-2" ] [ text t.units ]
        , div [ class "flex rounded-md shadow-sm max-w-xs" ]
            [ unitButton t.metric Metric selected "rounded-l-md"
            , unitButton t.imperial Imperial selected "rounded-r-md"
            ]
        ]


unitButton : String -> UnitSystem -> UnitSystem -> String -> Html Msg
unitButton labelStr unit selected roundedClass =
    let
        isSelected = unit == selected
        baseClasses = "flex-1 px-3 py-1.5 text-xs font-medium border focus:z-10 focus:ring-1 focus:ring-yellow-500"
        colors =
            if isSelected then
                "bg-yellow-100 text-yellow-800 border-yellow-300"
            else
                "bg-white text-gray-600 border-gray-300 hover:bg-gray-50"
    in
    button
        [ type_ "button"
        , class (baseClasses ++ " " ++ colors ++ " " ++ roundedClass)
        , onClick (SetUnits unit)
        , attribute "role" "radio"
        , attribute "aria-checked" (if isSelected then "true" else "false")
        ]
        [ text labelStr ]


viewLiquidWeightInput : BrineStrings -> Model -> Html Msg
viewLiquidWeightInput t model =
    let
        unit = if model.units == Metric then "g" else "oz"
        placeholderStr = if model.units == Metric then "e.g., 1000" else "e.g., 35.27"
    in
    div []
        [ label [ for "liquid-weight", class "block text-sm font-medium text-gray-700 mb-1" ] [ text (t.weightInput ++ " (" ++ unit ++ ")") ]
        , div [ class "relative rounded-md shadow-sm" ]
            [ input
                [ type_ "number"
                , id "liquid-weight"
                , class "focus:ring-yellow-500 focus:border-yellow-500 block w-full pr-12 sm:text-sm border-gray-300 rounded-md p-2 border"
                , placeholder placeholderStr
                , value model.liquidWeightInput
                , onInput SetLiquidWeight
                , step "any"
                ]
                []
            , div [ class "absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none" ]
                [ span [ class "text-gray-500 sm:text-sm" ] [ text unit ] ]
            ]
        ]


viewResult : BrineStrings -> BrineData -> Model -> Html Msg
viewResult t data model =
    let
        formatGrams g = String.fromFloat (round2dp g) ++ " g"
        formatOz g = String.fromFloat (round2dp (g / 28.3495)) ++ " oz"
        
        round2dp number =
            let
                multiplier = 100.0
                rounded = round (number * multiplier)
            in
            toFloat rounded / multiplier
    in
    case calculateAmounts data model of
        Just { saltMin, saltMax, sugar } ->
            div [ class "space-y-4 text-left inline-block" ]
                [ if model.proteinType == PorkPoultry then
                    div []
                        [ p [ class "font-bold text-gray-900" ] [ text t.salt ]
                        , p [ class "text-gray-800" ] 
                            [ text (formatGrams saltMin ++ " - " ++ formatGrams saltMax) ]
                        , p [ class "text-gray-500 text-xs" ] 
                            [ text (formatOz saltMin ++ " - " ++ formatOz saltMax) ]
                        ]
                  else
                    div []
                        [ p [ class "font-bold text-gray-900" ] [ text t.salt ]
                        , p [ class "text-gray-800" ] [ text (formatGrams saltMin) ]
                        , p [ class "text-gray-500 text-xs" ] [ text (formatOz saltMin) ]
                        ]
                , if sugar > 0 then
                    div []
                        [ p [ class "font-bold text-gray-900" ] [ text t.sugar ]
                        , p [ class "text-gray-800" ] [ text (formatGrams sugar) ]
                        , p [ class "text-gray-500 text-xs" ] [ text (formatOz sugar) ]
                        ]
                  else
                    text ""
                ]

        Nothing ->
            p [ class "text-gray-400 italic" ] [ text t.error ]