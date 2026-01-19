module Calculators.Heating exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- MODEL


type StartState
    = Thawed
    | Frozen

type Shape
    = Slab
    | Cylinder
    | Sphere

type alias Model =
    { startState : StartState
    , shape : Shape
    , thicknessInput : String
    }


init : Model
init =
    { startState = Thawed
    , shape = Slab
    , thicknessInput = "25"
    }


type Msg
    = SetStartState StartState
    | SetShape Shape
    | SetThickness String


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetStartState state ->
            { model | startState = state }

        SetShape shape ->
            { model | shape = shape }

        SetThickness val ->
            { model | thicknessInput = val }



-- DATA


{-| Returns heating time in minutes.
    Logic: Round thickness UP to nearest 5mm in table.
-}
getHeatingTime : StartState -> Shape -> Float -> Maybe Int
getHeatingTime state shape thickness =
    let
        -- Table stops at different points for different shapes
        maxThickness =
            case (state, shape) of
                (Thawed, Slab) -> 65
                (Thawed, Cylinder) -> 95
                (Thawed, Sphere) -> 115
                (Frozen, Slab) -> 65
                (Frozen, Cylinder) -> 95
                (Frozen, Sphere) -> 115

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
            else if thickness <= 75 then 75
            else if thickness <= 80 then 80
            else if thickness <= 85 then 85
            else if thickness <= 90 then 90
            else if thickness <= 95 then 95
            else if thickness <= 100 then 100
            else if thickness <= 105 then 105
            else if thickness <= 110 then 110
            else if thickness <= 115 then 115
            else 999 -- Too thick

        table =
            case state of
                Thawed -> thawedTable
                Frozen -> frozenTable
        
        -- Helper to extract the correct column (Slab, Cylinder, Sphere)
        getColumn row =
            case shape of
                Slab -> row.slab
                Cylinder -> row.cylinder
                Sphere -> row.sphere

    in
    if safeThickness > maxThickness then
        Nothing
        else
            table
                |> List.filter (\row -> row.thickness == safeThickness)
                |> List.head
                |> Maybe.andThen getColumn


type alias Row =
    { thickness : Int
    , slab : Maybe Int
    , cylinder : Maybe Int
    , sphere : Maybe Int
    }


-- Table 2.2: Thawed
thawedTable : List Row
thawedTable =
    [ { thickness = 5, slab = Just 5, cylinder = Just 5, sphere = Just 4 }
    , { thickness = 10, slab = Just 19, cylinder = Just 11, sphere = Just 8 }
    , { thickness = 15, slab = Just 35, cylinder = Just 18, sphere = Just 13 }
    , { thickness = 20, slab = Just 50, cylinder = Just 30, sphere = Just 20 }
    , { thickness = 25, slab = Just 75, cylinder = Just 40, sphere = Just 25 }
    , { thickness = 30, slab = Just 90, cylinder = Just 50, sphere = Just 35 }
    , { thickness = 35, slab = Just 120, cylinder = Just 60, sphere = Just 45 }
    , { thickness = 40, slab = Just 150, cylinder = Just 75, sphere = Just 55 }
    , { thickness = 45, slab = Just 180, cylinder = Just 90, sphere = Just 75 }
    , { thickness = 50, slab = Just 210, cylinder = Just 120, sphere = Just 90 }
    , { thickness = 55, slab = Just 240, cylinder = Just 135, sphere = Just 90 } -- Note: 90 is correct per text? Table says 1.5hr=90
    , { thickness = 60, slab = Just 285, cylinder = Just 150, sphere = Just 120 }
    , { thickness = 65, slab = Just 330, cylinder = Just 180, sphere = Just 135 }
    , { thickness = 70, slab = Nothing, cylinder = Just 210, sphere = Just 150 }
    , { thickness = 75, slab = Nothing, cylinder = Just 225, sphere = Just 165 }
    , { thickness = 80, slab = Nothing, cylinder = Just 255, sphere = Just 180 }
    , { thickness = 85, slab = Nothing, cylinder = Just 285, sphere = Just 210 }
    , { thickness = 90, slab = Nothing, cylinder = Just 315, sphere = Just 225 }
    , { thickness = 95, slab = Nothing, cylinder = Just 360, sphere = Just 255 }
    , { thickness = 100, slab = Nothing, cylinder = Nothing, sphere = Just 285 }
    , { thickness = 105, slab = Nothing, cylinder = Nothing, sphere = Just 300 }
    , { thickness = 110, slab = Nothing, cylinder = Nothing, sphere = Just 330 }
    , { thickness = 115, slab = Nothing, cylinder = Nothing, sphere = Just 360 }
    ]


-- Table 2.3: Frozen
frozenTable : List Row
frozenTable =
    [ { thickness = 5, slab = Just 7, cylinder = Just 7, sphere = Just 6 }
    , { thickness = 10, slab = Just 30, cylinder = Just 17, sphere = Just 12 }
    , { thickness = 15, slab = Just 50, cylinder = Just 30, sphere = Just 20 }
    , { thickness = 20, slab = Just 75, cylinder = Just 40, sphere = Just 30 }
    , { thickness = 25, slab = Just 105, cylinder = Just 55, sphere = Just 40 }
    , { thickness = 30, slab = Just 135, cylinder = Just 75, sphere = Just 55 }
    , { thickness = 35, slab = Just 180, cylinder = Just 90, sphere = Just 75 }
    , { thickness = 40, slab = Just 210, cylinder = Just 120, sphere = Just 90 }
    , { thickness = 45, slab = Just 270, cylinder = Just 150, sphere = Just 105 }
    , { thickness = 50, slab = Just 315, cylinder = Just 165, sphere = Just 120 }
    , { thickness = 55, slab = Just 375, cylinder = Just 195, sphere = Just 150 }
    , { thickness = 60, slab = Just 435, cylinder = Just 240, sphere = Just 165 }
    , { thickness = 65, slab = Just 495, cylinder = Just 270, sphere = Just 195 }
    , { thickness = 70, slab = Nothing, cylinder = Just 300, sphere = Just 225 }
    , { thickness = 75, slab = Nothing, cylinder = Just 345, sphere = Just 255 }
    , { thickness = 80, slab = Nothing, cylinder = Just 390, sphere = Just 285 }
    , { thickness = 85, slab = Nothing, cylinder = Just 435, sphere = Just 315 }
    , { thickness = 90, slab = Nothing, cylinder = Just 480, sphere = Just 345 }
    , { thickness = 95, slab = Nothing, cylinder = Just 525, sphere = Just 375 }
    , { thickness = 100, slab = Nothing, cylinder = Nothing, sphere = Just 420 }
    , { thickness = 105, slab = Nothing, cylinder = Nothing, sphere = Just 450 }
    , { thickness = 110, slab = Nothing, cylinder = Nothing, sphere = Just 495 }
    , { thickness = 115, slab = Nothing, cylinder = Nothing, sphere = Just 540 }
    ]


-- VIEW


view : Bool -> Model -> Html Msg
view isMetric model =
    div [ class "max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-sm" ]
        [ h2 [ class "text-2xl font-bold mb-6 text-gray-800 border-b pb-2" ]
            [ text "Heating Time Calculator" ]
        
        , div [ class "grid grid-cols-1 md:grid-cols-2 gap-8" ]
            [ -- Input Section
              div [ class "space-y-6" ]
                [ viewStateSelector model.startState
                , viewShapeSelector model.shape
                , viewInput isMetric "Thickness" model.thicknessInput SetThickness
                ]
            
            -- Result Section
            , div [ class "bg-indigo-50 rounded-lg p-6 flex flex-col justify-center items-center text-center" ]
                [ h3 [ class "text-lg font-medium text-indigo-800 mb-2" ] [ text "Time to Reach Temperature" ]
                , viewResult isMetric model
                ]
            ]
        ]


viewStateSelector : StartState -> Html Msg
viewStateSelector selected =
    div []
        [ label [ class "block text-sm font-medium text-gray-700 mb-2" ] [ text "Starting State" ]
        , div [ class "flex rounded-md shadow-sm" ]
            [ stateButton "Thawed / Fresh" Thawed selected "rounded-l-md"
            , stateButton "Frozen" Frozen selected "rounded-r-md"
            ]
        ]


stateButton : String -> StartState -> StartState -> String -> Html Msg
stateButton labelStr state selected roundedClass =
    let
        isSelected = state == selected
        baseClasses = "flex-1 px-4 py-2 text-sm font-medium border focus:z-10 focus:ring-2 focus:ring-indigo-500"
        colors =
            if isSelected then
                "bg-indigo-600 text-white border-indigo-600"
            else
                "bg-white text-gray-700 border-gray-300 hover:bg-gray-50"
    in
    button
        [ type_ "button"
        , class (baseClasses ++ " " ++ colors ++ " " ++ roundedClass)
        , onClick (SetStartState state)
        ]
        [ text labelStr ]


viewShapeSelector : Shape -> Html Msg
viewShapeSelector selected =
    div []
        [ label [ class "block text-sm font-medium text-gray-700 mb-2" ] [ text "Shape" ]
        , div [ class "grid grid-cols-1 gap-3 sm:grid-cols-3" ]
            [ shapeButton "Slab" Slab selected "Steak, Chops"
            , shapeButton "Cylinder" Cylinder selected "Roulade, Sausage"
            , shapeButton "Sphere" Sphere selected "Meatball, Roast"
            ]
        ]


shapeButton : String -> Shape -> Shape -> String -> Html Msg
shapeButton labelStr shape selected description =
    let
        isSelected = shape == selected
        baseClasses = "relative px-4 py-3 flex flex-col items-center justify-center text-sm font-medium rounded-md border shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        colors =
            if isSelected then
                "bg-indigo-50 text-indigo-700 border-indigo-200 ring-2 ring-indigo-500"
            else
                "bg-white text-gray-900 border-gray-300 hover:bg-gray-50"
    in
    button
        [ type_ "button"
        , class (baseClasses ++ " " ++ colors)
        , onClick (SetShape shape)
        ]
        [ span [ class "block font-bold" ] [ text labelStr ]
        , span [ class ("block text-xs mt-1 " ++ if isSelected then "text-indigo-500" else "text-gray-500") ] [ text description ]
        ]


viewInput : Bool -> String -> String -> (String -> Msg) -> Html Msg
viewInput isMetric labelStr valueStr msg =
    let
        unit = if isMetric then "mm" else "in"
        placeholderStr = if isMetric then "e.g., 25" else "e.g., 1.0"
    in
    div []
        [ label [ class "block text-sm font-medium text-gray-700 mb-1" ] [ text (labelStr ++ " (" ++ unit ++ ")") ]
        , div [ class "relative rounded-md shadow-sm" ]
            [ input
                [ type_ "number"
                , class "focus:ring-indigo-500 focus:border-indigo-500 block w-full pr-12 sm:text-sm border-gray-300 rounded-md p-2 border"
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


viewResult : Bool -> Model -> Html Msg
viewResult isMetric model =
    let
        thickness = String.toFloat model.thicknessInput
        
        mmThickness =
            thickness
                |> Maybe.map (\t -> if isMetric then t else t * 25.4)

        result =
            Maybe.andThen (getHeatingTime model.startState model.shape) mmThickness
    in
    case (thickness, result) of
        (Just _, Just minutes) ->
            let
                hours = minutes // 60
                mins = modBy 60 minutes
                
                timeString =
                    if hours > 0 then
                        String.fromInt hours ++ " hr " ++ String.fromInt mins ++ " min"
                    else
                        String.fromInt mins ++ " min"
            in
            div []
                [ span [ class "text-4xl font-extrabold text-indigo-900 block" ] [ text timeString ]
                , span [ class "text-sm text-indigo-600 mt-2 block" ] [ text "to reach 0.5°C (1°F) less than bath temp" ]
                ]

        (Just t, Nothing) ->
            let
                tVal = if isMetric then t else t * 25.4
                maxT = case (model.startState, model.shape) of
                    (_, Slab) -> 65
                    (_, Cylinder) -> 95
                    (_, Sphere) -> 115
            in
            p [ class "text-red-600 font-medium" ] [ text ("Thickness exceeds table limit (" ++ String.fromInt maxT ++ "mm).") ]

        _ ->
            p [ class "text-gray-400 italic" ] [ text "Enter a valid thickness..." ]
