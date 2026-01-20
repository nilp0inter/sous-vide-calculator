module Calculators.Pasteurization exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Slider
import Round
import Data exposing (PasteurizationData, PasteurizationRow)


-- MODEL


type Protein
    = LeanFish
    | FattyFish
    | Poultry
    | Meat

type alias Model =
    {
        protein : Protein
    , thicknessInput : Float
    , tempInput : Float
    , isAcidicMarinade : Bool
    }


init : Model
init =
    {
        protein = Meat
    , thicknessInput = 25.0
    , tempInput = 58.0
    , isAcidicMarinade = False
    }


type Msg
    = SetProtein Protein
    | SetThickness Float
    | SetTemp Float
    | ToggleAcidicMarinade


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetProtein protein ->
            { model | protein = protein }

        SetThickness val ->
            { model | thicknessInput = val }

        SetTemp val ->
            { model | tempInput = val }

        ToggleAcidicMarinade ->
            { model | isAcidicMarinade = not model.isAcidicMarinade }



-- DATA


{-| Returns the pasteurization time in minutes for a given protein, thickness (mm), and temperature (C).
-}
getPasteurizationTime : PasteurizationData -> Protein -> Float -> Float -> Maybe Float
getPasteurizationTime data protein thickness temp =
    let
        -- Safety Rule: Round thickness UP to the nearest 5mm step in the table
        -- Slider ensures valid input, but keep logic safe
        safeThickness = round thickness

        -- Safety Rule: Round temperature DOWN to the nearest available column
        table = getTable data protein

        findTimeForThickness tList =
            tList
                |> List.filter (\row -> row.thickness == toFloat safeThickness)
                |> List.head
                |> Maybe.andThen (\row -> findTimeForTemp row.times)

        findTimeForTemp tempMap =
            tempMap
                |> List.filter (\(t, _) -> t <= temp)
                |> List.sortBy (\(t, _) -> t)
                |> List.reverse
                |> List.head
                |> Maybe.map Tuple.second
    in
    findTimeForThickness table


getTable : PasteurizationData -> Protein -> List PasteurizationRow
getTable data protein =
    case protein of
        LeanFish -> data.leanFish
        FattyFish -> data.fattyFish
        Poultry -> data.poultry
        Meat -> data.meat


-- VIEW


view : PasteurizationData -> Model -> Html Msg
view data model =
    div [ class "max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-sm" ]
        [ h2 [ class "text-2xl font-bold mb-6 text-gray-800 border-b pb-2" ]
            [ text "Pasteurization Calculator" ]
        
        , div [ class "grid grid-cols-1 md:grid-cols-2 gap-8" ]
            [ -- Input Section
              div [ class "space-y-6" ]
                [ viewProteinSelector model.protein
                , viewThicknessSlider data model
                , viewTempSlider data model
                , viewMarinadeToggle model.isAcidicMarinade
                ]
            
            -- Result Section
            , div [ class "bg-blue-50 rounded-lg p-6 flex flex-col justify-center items-center text-center" ]
                [ h3 [ class "text-lg font-medium text-blue-800 mb-2" ] [ text "Minimum Time" ]
                , viewResult data model
                ]
            ]
        ]


viewProteinSelector : Protein -> Html Msg
viewProteinSelector selected =
    div []
        [ label [ class "block text-sm font-medium text-gray-700 mb-2" ] [ text "Protein Type" ]
        , div [ class "grid grid-cols-2 gap-3" ]
            [ proteinButton "Meat (Beef/Pork/Lamb)" Meat selected
            , proteinButton "Poultry" Poultry selected
            , proteinButton "Lean Fish" LeanFish selected
            , proteinButton "Fatty Fish" FattyFish selected
            ]
        ]


proteinButton : String -> Protein -> Protein -> Html Msg
proteinButton labelStr protein selected =
    let
        isSelected = protein == selected
        baseClasses = "px-3 py-2 text-sm font-medium rounded-md transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        colors =
            if isSelected then
                "bg-blue-600 text-white shadow-sm"
            else
                "bg-white text-gray-700 border border-gray-300 hover:bg-gray-50"
    in
    button
        [ type_ "button"
        , class (baseClasses ++ " " ++ colors)
        , onClick (SetProtein protein)
        ]
        [ text labelStr ]


viewThicknessSlider : PasteurizationData -> Model -> Html Msg
viewThicknessSlider data model =
    let
        table = getTable data model.protein
        thicknesses = List.map .thickness table |> List.sort
        
        formatter val =
            let
                mm = String.fromFloat val ++ " mm"
                inch = Round.round 2 (val / 25.4) ++ " in"
            in
            mm ++ " / " ++ inch
    in
    Slider.view
        {
            value = model.thicknessInput
        ,   allowedValues = thicknesses
        ,   toMsg = SetThickness
        ,   label = "Thickness"
        ,   formatter = formatter
        }


viewTempSlider : PasteurizationData -> Model -> Html Msg
viewTempSlider data model =
    let
        table = getTable data model.protein
        
        -- Extract valid temperatures from the first row (assuming all rows have same temp cols)
        -- The inner list is [(Temp, Time), ...]
        validTemps =
            table
                |> List.head
                |> Maybe.map .times
                |> Maybe.withDefault []
                |> List.map Tuple.first
                |> List.sort

        formatter val =
            let
                c = String.fromFloat val ++ " °C"
                f = Round.round 1 ((val * 9/5) + 32) ++ " °F"
            in
            c ++ " / " ++ f
    in
    Slider.view
        {
            value = model.tempInput
        ,   allowedValues = validTemps
        ,   toMsg = SetTemp
        ,   label = "Bath Temperature"
        ,   formatter = formatter
        }


viewMarinadeToggle : Bool -> Html Msg
viewMarinadeToggle isAcidic =
    div [ class "flex items-start" ]
        [ div [ class "flex items-center h-5" ]
            [
                input
                    [
                        type_ "checkbox"
                    , class "focus:ring-blue-500 h-4 w-4 text-blue-600 border-gray-300 rounded"
                    , checked isAcidic
                    , onClick ToggleAcidicMarinade
                    ]
                    []
            ]
        , div [ class "ml-3 text-sm" ]
            [ label [ class "font-medium text-gray-700" ] [ text "Safety Buffer (Acidic Marinade)" ]
            , p [ class "text-gray-500" ] [ text "Double pasteurization time if using an acidic marinade." ]
            ]
        ]


viewResult : PasteurizationData -> Model -> Html Msg
viewResult data model =
    let
        result =
            getPasteurizationTime data model.protein model.thicknessInput model.tempInput
    in
    case result of
        Just rawMinutes ->
            let
                finalMinutes =
                    if model.isAcidicMarinade then
                        rawMinutes * 2
                    else
                        rawMinutes
                
                hours = floor (finalMinutes / 60)
                mins = round (finalMinutes - (toFloat hours * 60))
                
                timeString =
                    if hours > 0 then
                        String.fromInt hours ++ " hr " ++ String.fromInt mins ++ " min"
                    else
                        String.fromInt mins ++ " min"
            in
            div []
                [ span [ class "text-4xl font-extrabold text-gray-900 block" ] [ text timeString ]
                , if model.isAcidicMarinade then
                    span [ class "text-sm text-amber-600 font-medium mt-2 block" ] [ text "(Doubled for safety)" ]
                  else
                    text ""
                ]

        Nothing ->
             -- Slider prevents this mostly, but thickness > 70 still possible if we didn't filter logic
            if model.thicknessInput > 70 then
                 p [ class "text-red-600 font-medium" ] [ text "Thickness exceeds 70mm table limit." ]
            else
                 p [ class "text-amber-600 font-medium" ] [ text "Temperature out of range for this protein." ]