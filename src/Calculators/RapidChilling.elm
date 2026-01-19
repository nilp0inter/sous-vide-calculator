module Calculators.RapidChilling exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Slider
import Round


-- MODEL


type Shape
    = Slab
    | Cylinder
    | Sphere


type alias Model =
    { shape : Shape
    , thicknessInput : Float
    }


init : Model
init =
    { shape = Slab
    , thicknessInput = 25.0
    }


type Msg
    = SetShape Shape
    | SetThickness Float


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetShape shape ->
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
        Slab -> 75
        Cylinder -> 110
        Sphere -> 115


-- DATA


{-| Returns cooling time in minutes.
    Logic: Round thickness UP to nearest 5mm in table.
-}
getCoolingTime : Shape -> Float -> Maybe Int
getCoolingTime shape thickness =
    let
        maxThickness = getMaxThickness shape

        safeThickness = round thickness
        
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
        table1_1
            |> List.filter (\row -> row.thickness == safeThickness)
            |> List.head
            |> Maybe.andThen getColumn

type alias TableRow =
    { thickness : Int
    , slab : Maybe Int
    , cylinder : Maybe Int
    , sphere : Maybe Int
    }


-- Table 1.1: Cooling Time to 41°F (5°C) in Ice Water
table1_1 : List TableRow
table1_1 =
    [ { thickness = 5, slab = Just 5, cylinder = Just 3, sphere = Just 3 }
    , { thickness = 10, slab = Just 14, cylinder = Just 8, sphere = Just 6 }
    , { thickness = 15, slab = Just 25, cylinder = Just 14, sphere = Just 10 }
    , { thickness = 20, slab = Just 35, cylinder = Just 20, sphere = Just 15 }
    , { thickness = 25, slab = Just 50, cylinder = Just 30, sphere = Just 20 }
    , { thickness = 30, slab = Just 75, cylinder = Just 40, sphere = Just 30 }
    , { thickness = 35, slab = Just 90, cylinder = Just 50, sphere = Just 35 }
    , { thickness = 40, slab = Just 105, cylinder = Just 60, sphere = Just 45 }
    , { thickness = 45, slab = Just 135, cylinder = Just 75, sphere = Just 55 }
    , { thickness = 50, slab = Just 165, cylinder = Just 90, sphere = Just 60 }
    , { thickness = 55, slab = Just 195, cylinder = Just 105, sphere = Just 75 }
    , { thickness = 60, slab = Just 225, cylinder = Just 120, sphere = Just 90 }
    , { thickness = 65, slab = Just 255, cylinder = Just 135, sphere = Just 105 }
    , { thickness = 70, slab = Just 285, cylinder = Just 165, sphere = Just 120 }
    , { thickness = 75, slab = Just 330, cylinder = Just 180, sphere = Just 135 }
    , { thickness = 80, slab = Nothing, cylinder = Just 210, sphere = Just 150 }
    , { thickness = 85, slab = Nothing, cylinder = Just 225, sphere = Just 165 }
    , { thickness = 90, slab = Nothing, cylinder = Just 255, sphere = Just 180 }
    , { thickness = 95, slab = Nothing, cylinder = Just 285, sphere = Just 210 }
    , { thickness = 100, slab = Nothing, cylinder = Just 300, sphere = Just 225 }
    , { thickness = 105, slab = Nothing, cylinder = Just 330, sphere = Just 240 }
    , { thickness = 110, slab = Nothing, cylinder = Just 360, sphere = Just 270 }
    , { thickness = 115, slab = Nothing, cylinder = Nothing, sphere = Just 285 }
    ]


-- VIEW


view : Model -> Html Msg
view model =
    div [ class "max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-sm" ]
        [ h2 [ class "text-2xl font-bold mb-6 text-gray-800 border-b pb-2" ]
            [ text "Rapid Chilling (Cook-Chill) Calculator" ]
        
        , div [ class "grid grid-cols-1 md:grid-cols-2 gap-8" ]
            [ -- Input Section
              div [ class "space-y-6" ]
                [ viewShapeSelector model.shape
                , viewThicknessSlider model
                ]
            
            -- Result Section
            , div [ class "bg-emerald-50 rounded-lg p-6 flex flex-col justify-center items-center text-center" ]
                [ h3 [ class "text-lg font-medium text-emerald-800 mb-2" ] [ text "Cooling Time" ]
                , viewResult model
                ]
            ]
        ]


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
        baseClasses = "relative px-4 py-3 flex flex-col items-center justify-center text-sm font-medium rounded-md border shadow-sm focus:outline-none focus:ring-2 focus:ring-emerald-500"
        colors =
            if isSelected then
                "bg-emerald-50 text-emerald-700 border-emerald-200 ring-2 ring-emerald-500"
            else
                "bg-white text-gray-900 border-gray-300 hover:bg-gray-50"
    in
    button
        [ type_ "button"
        , class (baseClasses ++ " " ++ colors)
        , onClick (SetShape shape)
        ]
        [ span [ class "block font-bold" ] [ text labelStr ]
        , span [ class ("block text-xs mt-1 " ++ if isSelected then "text-emerald-500" else "text-gray-500") ] [ text description ]
        ]


viewThicknessSlider : Model -> Html Msg
viewThicknessSlider model =
    let
        maxT = getMaxThickness model.shape
        
        allThicknesses = 
            table1_1
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
            getCoolingTime model.shape model.thicknessInput
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
                [ span [ class "text-4xl font-extrabold text-emerald-900 block" ] [ text timeString ]
                , span [ class "text-sm text-emerald-600 mt-2 block" ] [ text "in ice water (at least half ice) to reach 5°C (41°F)" ]
                ]

        Nothing ->
            p [ class "text-red-600 font-medium" ] [ text "Thickness out of range." ]