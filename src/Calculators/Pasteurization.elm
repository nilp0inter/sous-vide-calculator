module Calculators.Pasteurization exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- MODEL


type Protein
    = LeanFish
    | FattyFish
    | Poultry
    | Meat

type alias Model =
    {
        protein : Protein
    , thicknessInput : String
    , tempInput : String
    , isAcidicMarinade : Bool
    }


init : Model
init =
    {
        protein = Meat
    , thicknessInput = "25"
    , tempInput = "58"
    , isAcidicMarinade = False
    }


type Msg
    = SetProtein Protein
    | SetThickness String
    | SetTemp String
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
        safeThickness =
            if thickness <= 5 then 5
            else if thickness <= 10 then 10
            else if thickness <= 15 then 15
            else if thickness <= 20 then 20
            else if thickness <= 25 then 25
            else if thickness <= 30 then 30
            else if thickness <= 35 then 35
            else if thickness <= 40 then 40
            else if thickness <= 45 then 45
            else if thickness <= 50 then 50
            else if thickness <= 55 then 55
            else if thickness <= 60 then 60
            else if thickness <= 65 then 65
            else if thickness <= 70 then 70
            else 999 -- Too thick

        -- Safety Rule: Round temperature DOWN to the nearest available column
        -- (because lower temp = longer time required, so rounding down is safer)
        table =
            case protein of
                LeanFish -> leanFishTable
                FattyFish -> fattyFishTable
                Poultry -> poultryTable
                Meat -> meatTable

        findTimeForThickness tList =
            tList
                |> List.filter (\(t, _) -> t == safeThickness)
                |> List.head
                |> Maybe.andThen (\(_, tempMap) -> findTimeForTemp tempMap)

        findTimeForTemp tempMap =
            -- tempMap is sorted descending by temp usually, or we just filter
            -- We want the highest temp key that is <= our input temp.
            -- Actually, simpler: List.filter (key <= input) -> take max of those keys?
            -- Since our table rows are (Temp, Time), and we want to match the
            -- explicit columns.
            -- Example: Input 55.5. Keys: 55, 56.
            -- 55.5 is hotter than 55. So 55's time is safe.
            -- 55.5 is colder than 56. So 56's time is UNSAFE (too short).
            -- So we look for the key that is <= input. The largest such key.
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


view : Bool -> Model -> Html Msg
view isMetric model =
    div [ class "max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-sm" ]
        [ h2 [ class "text-2xl font-bold mb-6 text-gray-800 border-b pb-2" ]
            [ text "Pasteurization Calculator" ]
        
        , div [ class "grid grid-cols-1 md:grid-cols-2 gap-8" ]
            [ -- Input Section
              div [ class "space-y-6" ]
                [ viewProteinSelector model.protein
                , viewInput isMetric "Thickness" model.thicknessInput SetThickness
                , viewInputTemp isMetric "Bath Temperature" model.tempInput SetTemp
                , viewMarinadeToggle model.isAcidicMarinade
                ]
            
            -- Result Section
            , div [ class "bg-blue-50 rounded-lg p-6 flex flex-col justify-center items-center text-center" ]
                [ h3 [ class "text-lg font-medium text-blue-800 mb-2" ] [ text "Minimum Time" ]
                , viewResult isMetric model
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


viewInput : Bool -> String -> String -> (String -> Msg) -> Html Msg
viewInput isMetric labelStr valueStr msg =
    let
        unit = if isMetric then "mm" else "in"
        placeholderStr = if isMetric then "e.g., 25" else "e.g., 1.0"
    in
    div []
        [ label [ class "block text-sm font-medium text-gray-700 mb-1" ] [ text (labelStr ++ " (" ++ unit ++ ")") ]
        , div [ class "relative rounded-md shadow-sm" ]
            [
                input
                    [
                        type_ "number"
                    , class "focus:ring-blue-500 focus:border-blue-500 block w-full pr-12 sm:text-sm border-gray-300 rounded-md p-2 border"
                    , placeholder placeholderStr
                    , value valueStr
                    , onInput msg
                    , step "any"
                    ]
                    []
            , div [ class "absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none" ]
                [ span [ class "text-gray-500 sm:text-sm" ] [ text unit ] ]
            ]
        ]


viewInputTemp : Bool -> String -> String -> (String -> Msg) -> Html Msg
viewInputTemp isMetric labelStr valueStr msg =
    let
        unit = if isMetric then "°C" else "°F"
        placeholderStr = if isMetric then "e.g., 58" else "e.g., 136"
    in
    div []
        [ label [ class "block text-sm font-medium text-gray-700 mb-1" ] [ text (labelStr ++ " (" ++ unit ++ ")") ]
        , div [ class "relative rounded-md shadow-sm" ]
            [
                input
                    [
                        type_ "number"
                    , class "focus:ring-blue-500 focus:border-blue-500 block w-full pr-12 sm:text-sm border-gray-300 rounded-md p-2 border"
                    , placeholder placeholderStr
                    , value valueStr
                    , onInput msg
                    , step "any"
                    ]
                    []
            , div [ class "absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none" ]
                [ span [ class "text-gray-500 sm:text-sm" ] [ text unit ] ]
            ]
        ]


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


viewResult : Bool -> Model -> Html Msg
viewResult isMetric model =
    let
        thickness = String.toFloat model.thicknessInput
        temp = String.toFloat model.tempInput
        
        -- Convert to Metric for calculation
        mmThickness =
            thickness
                |> Maybe.map (\t -> if isMetric then t else t * 25.4)
        
        cTemp =
            temp
                |> Maybe.map (\t -> if isMetric then t else (t - 32) * 5 / 9)

        result =
            Maybe.map2 (getPasteurizationTime model.protein) mmThickness cTemp
                |> Maybe.andThen identity
    in
    case (thickness, temp, result) of
        (Just _, Just _, Just rawMinutes) ->
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

        (Just t, Just _, Nothing) ->
            let
                tVal = if isMetric then t else t * 25.4
            in
            if tVal > 70 then
                 p [ class "text-red-600 font-medium" ] [ text "Thickness exceeds 70mm table limit." ]
            else
                 p [ class "text-amber-600 font-medium" ] [ text "Temperature out of range for this protein." ]

        _ ->
            p [ class "text-gray-400 italic" ] [ text "Enter valid thickness and temperature..." ]
