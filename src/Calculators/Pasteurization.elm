module Calculators.Pasteurization exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Slider
import Round


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
getPasteurizationTime : Protein -> Float -> Float -> Maybe Float
getPasteurizationTime protein thickness temp =
    let
        -- Safety Rule: Round thickness UP to the nearest 5mm step in the table
        -- Slider ensures valid input, but keep logic safe
        safeThickness = round thickness

        -- Safety Rule: Round temperature DOWN to the nearest available column
        table = getTable protein

        findTimeForThickness tList =
            tList
                |> List.filter (\(t, _) -> t == toFloat safeThickness)
                |> List.head
                |> Maybe.andThen (\(_, tempMap) -> findTimeForTemp tempMap)

        findTimeForTemp tempMap =
            tempMap
                |> List.filter (\(t, _) -> t <= temp)
                |> List.sortBy (\(t, _) -> t)
                |> List.reverse
                |> List.head
                |> Maybe.map Tuple.second
    in
    findTimeForThickness table


type alias TableRow = (Float, Float) -- (Temp, Minutes)
type alias TableData = List (Float, List TableRow) -- (Thickness, Row)

getTable : Protein -> TableData
getTable protein =
    case protein of
        LeanFish -> leanFishTable
        FattyFish -> fattyFishTable
        Poultry -> poultryTable
        Meat -> meatTable


-- Table 3.1: Lean Fish
leanFishTable : TableData
leanFishTable =
    [
        (5, [(55, 150), (56, 105), (57, 75), (58, 50), (59, 35), (60, 30)])
    , (10, [(55, 165), (56, 120), (57, 90), (58, 60), (59, 45), (60, 35)])
    , (15, [(55, 165), (56, 120), (57, 90), (58, 75), (59, 55), (60, 50)])
    , (20, [(55, 180), (56, 135), (57, 105), (58, 90), (59, 75), (60, 60)])
    , (25, [(55, 195), (56, 150), (57, 120), (58, 105), (59, 90), (60, 75)])
    , (30, [(55, 225), (56, 180), (57, 150), (58, 120), (59, 105), (60, 105)])
    , (35, [(55, 240), (56, 195), (57, 165), (58, 150), (59, 135), (60, 120)])
    , (40, [(55, 270), (56, 225), (57, 180), (58, 165), (59, 150), (60, 135)])
    , (45, [(55, 285), (56, 240), (57, 210), (58, 195), (59, 165), (60, 150)])
    , (50, [(55, 315), (56, 270), (57, 240), (58, 210), (59, 195), (60, 180)])
    , (55, [(55, 345), (56, 300), (57, 270), (58, 240), (59, 225), (60, 210)])
    , (60, [(55, 375), (56, 330), (57, 300), (58, 270), (59, 240), (60, 225)])
    , (65, [(55, 420), (56, 360), (57, 330), (58, 300), (59, 270), (60, 255)])
    , (70, [(55, 450), (56, 405), (57, 360), (58, 330), (59, 300), (60, 285)])
    ]

-- Table 3.1: Fatty Fish
fattyFishTable : TableData
fattyFishTable =
    [
        (5, [(55, 255), (56, 180), (57, 120), (58, 90), (59, 60), (60, 40)])
    , (10, [(55, 255), (56, 180), (57, 120), (58, 90), (59, 75), (60, 50)])
    , (15, [(55, 270), (56, 195), (57, 135), (58, 105), (59, 75), (60, 60)])
    , (20, [(55, 285), (56, 210), (57, 150), (58, 120), (59, 90), (60, 75)])
    , (25, [(55, 300), (56, 225), (57, 165), (58, 135), (59, 105), (60, 90)])
    , (30, [(55, 315), (56, 240), (57, 195), (58, 150), (59, 135), (60, 120)])
    , (35, [(55, 330), (56, 255), (57, 210), (58, 180), (59, 150), (60, 135)])
    , (40, [(55, 360), (56, 285), (57, 240), (58, 195), (59, 180), (60, 150)])
    , (45, [(55, 390), (56, 315), (57, 255), (58, 225), (59, 195), (60, 180)])
    , (50, [(55, 420), (56, 345), (57, 285), (58, 255), (59, 225), (60, 195)])
    , (55, [(55, 450), (56, 375), (57, 315), (58, 285), (59, 255), (60, 225)])
    , (60, [(55, 480), (56, 405), (57, 345), (58, 315), (59, 285), (60, 255)])
    , (65, [(55, 510), (56, 435), (57, 375), (58, 345), (59, 315), (60, 285)])
    , (70, [(55, 555), (56, 480), (57, 420), (58, 375), (59, 345), (60, 315)])
    ]

-- Table 4.1: Poultry
-- 134.5F=57C, 136.5F=58C, 138F=59C, 140F=60C, 142F=61C, 143.5F=62C, 145.5F=63C, 147F=64C, 149F=65C
poultryTable : TableData
poultryTable =
    [
        (5, [(57, 135), (58, 105), (59, 75), (60, 45), (61, 35), (62, 25), (63, 18), (64, 15), (65, 13)])
    , (10, [(57, 135), (58, 105), (59, 75), (60, 55), (61, 40), (62, 35), (63, 30), (64, 25), (65, 20)])
    , (15, [(57, 150), (58, 105), (59, 90), (60, 75), (61, 50), (62, 45), (63, 40), (64, 35), (65, 30)])
    , (20, [(57, 165), (58, 120), (59, 105), (60, 75), (61, 75), (62, 55), (63, 50), (64, 45), (65, 40)])
    , (25, [(57, 180), (58, 135), (59, 120), (60, 90), (61, 90), (62, 75), (63, 75), (64, 60), (65, 55)])
    , (30, [(57, 195), (58, 165), (59, 135), (60, 120), (61, 105), (62, 90), (63, 90), (64, 75), (65, 75)])
    , (35, [(57, 225), (58, 180), (59, 150), (60, 135), (61, 120), (62, 105), (63, 105), (64, 90), (65, 90)])
    , (40, [(57, 240), (58, 195), (59, 165), (60, 150), (61, 135), (62, 120), (63, 120), (64, 105), (65, 105)])
    , (45, [(57, 270), (58, 225), (59, 195), (60, 180), (61, 165), (62, 150), (63, 135), (64, 120), (65, 120)])
    , (50, [(57, 285), (58, 255), (59, 225), (60, 195), (61, 180), (62, 165), (63, 150), (64, 150), (65, 135)])
    , (55, [(57, 315), (58, 270), (59, 240), (60, 225), (61, 210), (62, 195), (63, 180), (64, 165), (65, 165)])
    , (60, [(57, 345), (58, 300), (59, 270), (60, 255), (61, 225), (62, 210), (63, 195), (64, 195), (65, 180)])
    , (65, [(57, 375), (58, 330), (59, 300), (60, 270), (61, 255), (62, 240), (63, 225), (64, 210), (65, 195)])
    , (70, [(57, 420), (58, 360), (59, 330), (60, 300), (61, 285), (62, 270), (63, 255), (64, 240), (65, 225)])
    ]

-- Table 5.1: Meat
meatTable : TableData
meatTable =
    [
        (5, [(55, 120), (56, 75), (57, 60), (58, 45), (59, 40), (60, 30), (61, 25), (62, 25), (63, 18), (64, 16), (65, 14), (66, 13)])
    , (10, [(55, 120), (56, 90), (57, 75), (58, 55), (59, 45), (60, 40), (61, 35), (62, 30), (63, 30), (64, 25), (65, 25), (66, 25)])
    , (15, [(55, 135), (56, 105), (57, 90), (58, 75), (59, 60), (60, 55), (61, 50), (62, 45), (63, 40), (64, 40), (65, 35), (66, 35)])
    , (20, [(55, 150), (56, 120), (57, 105), (58, 90), (59, 75), (60, 75), (61, 60), (62, 55), (63, 55), (64, 50), (65, 45), (66, 45)])
    , (25, [(55, 165), (56, 135), (57, 120), (58, 105), (59, 90), (60, 90), (61, 75), (62, 75), (63, 75), (64, 60), (65, 55), (66, 55)])
    , (30, [(55, 180), (56, 150), (57, 120), (58, 120), (59, 105), (60, 90), (61, 90), (62, 90), (63, 75), (64, 75), (65, 75), (66, 75)])
    , (35, [(55, 195), (56, 165), (57, 135), (58, 120), (59, 120), (60, 105), (61, 105), (62, 90), (63, 90), (64, 90), (65, 75), (66, 75)])
    , (40, [(55, 210), (56, 180), (57, 150), (58, 135), (59, 135), (60, 120), (61, 105), (62, 105), (63, 105), (64, 90), (65, 90), (66, 90)])
    , (45, [(55, 240), (56, 195), (57, 180), (58, 165), (59, 150), (60, 135), (61, 135), (62, 120), (63, 120), (64, 105), (65, 105), (66, 105)])
    , (50, [(55, 270), (56, 225), (57, 195), (58, 180), (59, 165), (60, 150), (61, 150), (62, 135), (63, 135), (64, 120), (65, 120), (66, 120)])
    , (55, [(55, 300), (56, 255), (57, 225), (58, 210), (59, 180), (60, 180), (61, 165), (62, 165), (63, 150), (64, 150), (65, 135), (66, 135)])
    , (60, [(55, 315), (56, 285), (57, 255), (58, 225), (59, 210), (60, 195), (61, 180), (62, 180), (63, 165), (64, 165), (65, 150), (66, 150)])
    , (65, [(55, 360), (56, 315), (57, 285), (58, 255), (59, 240), (60, 225), (61, 210), (62, 195), (63, 195), (64, 180), (65, 180), (66, 165)])
    , (70, [(55, 390), (56, 345), (57, 315), (58, 285), (59, 255), (60, 240), (61, 225), (62, 225), (63, 210), (64, 195), (65, 195), (66, 195)])
    ]


-- VIEW


view : Model -> Html Msg
view model =
    div [ class "max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-sm" ]
        [ h2 [ class "text-2xl font-bold mb-6 text-gray-800 border-b pb-2" ]
            [ text "Pasteurization Calculator" ]
        
        , div [ class "grid grid-cols-1 md:grid-cols-2 gap-8" ]
            [ -- Input Section
              div [ class "space-y-6" ]
                [ viewProteinSelector model.protein
                , viewThicknessSlider model
                , viewTempSlider model
                , viewMarinadeToggle model.isAcidicMarinade
                ]
            
            -- Result Section
            , div [ class "bg-blue-50 rounded-lg p-6 flex flex-col justify-center items-center text-center" ]
                [ h3 [ class "text-lg font-medium text-blue-800 mb-2" ] [ text "Minimum Time" ]
                , viewResult model
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


viewThicknessSlider : Model -> Html Msg
viewThicknessSlider model =
    let
        table = getTable model.protein
        thicknesses = List.map Tuple.first table |> List.sort
        
        formatter val =
            let
                mm = String.fromFloat val ++ " mm"
                inch = Round.round 2 (val / 25.4) ++ " in"
            in
            mm ++ " / " ++ inch
    in
    Slider.view
        { value = model.thicknessInput
        , allowedValues = thicknesses
        , toMsg = SetThickness
        , label = "Thickness"
        , formatter = formatter
        }


viewTempSlider : Model -> Html Msg
viewTempSlider model =
    let
        table = getTable model.protein
        
        -- Extract valid temperatures from the first row (assuming all rows have same temp cols)
        -- The inner list is [(Temp, Time), ...]
        validTemps = 
            table 
                |> List.head 
                |> Maybe.map Tuple.second 
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
        { value = model.tempInput
        , allowedValues = validTemps
        , toMsg = SetTemp
        , label = "Bath Temperature"
        , formatter = formatter
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


viewResult : Model -> Html Msg
viewResult model =
    let
        result =
            getPasteurizationTime model.protein model.thicknessInput model.tempInput
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

