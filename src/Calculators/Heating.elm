module Calculators.Heating exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Slider
import Round


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
    , thicknessInput : Float
    }


init : Model
init =
    { startState = Thawed
    , shape = Slab
    , thicknessInput = 25.0
    }


type Msg
    = SetStartState StartState
    | SetShape Shape
    | SetThickness Float


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetStartState state ->
            { model | startState = state }

        SetShape shape ->
            -- If the current thickness is invalid for the new shape, clamp it?
            -- The slider will handle it by snapping to the nearest valid, 
            -- but the Model value needs to be valid.
            -- We'll just let the view filter the options. 
            -- Ideally we should clamp here, but simpler to just let user adjust.
            -- Actually, if we switch shape to Slab and thickness is 115, that's invalid.
            -- Let's clamp it to the new max.
            let
                maxT = getMaxThickness shape
                newThickness = Basics.min model.thicknessInput (toFloat maxT)
            in
            { model | shape = shape, thicknessInput = newThickness }

        SetThickness val ->
            { model | thicknessInput = val }


getMaxThickness : Shape -> Int
getMaxThickness shape =
    case shape of
        Slab -> 65
        Cylinder -> 95
        Sphere -> 115


-- DATA


{-| Returns heating time in minutes.
    Logic: Round thickness UP to nearest 5mm in table.
-}
getHeatingTime : StartState -> Shape -> Float -> Maybe Int
getHeatingTime state shape thickness =
    let
        maxThickness = getMaxThickness shape

        -- The slider gives us exact table values, but safe to keep this logic
        safeThickness = round thickness
        
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
    , { thickness = 55, slab = Just 240, cylinder = Just 135, sphere = Just 90 }
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


view : Model -> Html Msg
view model =
    div [ class "max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-sm" ]
        [ h2 [ class "text-2xl font-bold mb-6 text-gray-800 border-b pb-2" ]
            [ text "Heating Time Calculator" ]
        
        , div [ class "grid grid-cols-1 md:grid-cols-2 gap-8" ]
            [ -- Input Section
              div [ class "space-y-6" ]
                [ viewStateSelector model.startState
                , viewShapeSelector model.shape
                , viewThicknessSlider model
                ]
            
            -- Result Section
            , div [ class "bg-indigo-50 rounded-lg p-6 flex flex-col justify-center items-center text-center" ]
                [ h3 [ class "text-lg font-medium text-indigo-800 mb-2" ] [ text "Time to Reach Temperature" ]
                , viewResult model
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


viewThicknessSlider : Model -> Html Msg
viewThicknessSlider model =
    let
        maxT = getMaxThickness model.shape
        
        allThicknesses = 
            thawedTable
                |> List.map (.thickness >> toFloat)
        
        allowed = 
            List.filter (\t -> t <= toFloat maxT) allThicknesses

        formatter val =
            let
                mm = String.fromFloat val ++ " mm"
                inch = Round.round 2 (val / 25.4) ++ " in"
            in
            mm ++ " / " ++ inch
    in
    Slider.view
        { value = model.thicknessInput
        , allowedValues = allowed
        , toMsg = SetThickness
        , label = "Thickness"
        , formatter = formatter
        }


viewResult : Model -> Html Msg
viewResult model =
    let
        result =
            getHeatingTime model.startState model.shape model.thicknessInput
    in
    case result of
        Just minutes ->
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

        Nothing ->
             -- Should not happen with slider limits, but safe to keep
            p [ class "text-red-600 font-medium" ] [ text "Thickness out of range." ]

