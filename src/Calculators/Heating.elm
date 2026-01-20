module Calculators.Heating exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Slider
import Round
import Data exposing (HeatingData, HeatingRow)
import Translations exposing (HeatingStrings, AppStrings)


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


update : HeatingData -> Msg -> Model -> Model
update data msg model =
    case msg of
        SetStartState state ->
            { model | startState = state }

        SetShape shape ->
            let
                maxT = getMaxThickness data model.startState shape
                newThickness = Basics.min model.thicknessInput (toFloat maxT)
            in
            { model | shape = shape, thicknessInput = newThickness }

        SetThickness val ->
            { model | thicknessInput = val }


getMaxThickness : HeatingData -> StartState -> Shape -> Int
getMaxThickness data state shape =
    let
        table =
            case state of
                Thawed -> data.thawed
                Frozen -> data.frozen
        
        hasValue row =
            case shape of
                Slab -> row.slab /= Nothing
                Cylinder -> row.cylinder /= Nothing
                Sphere -> row.sphere /= Nothing
    in
    table
        |> List.filter hasValue
        |> List.map .thickness
        |> List.maximum
        |> Maybe.withDefault 0


-- DATA


{-| Returns heating time in minutes.
    Logic: Round thickness UP to nearest 5mm in table.
-}
getHeatingTime : HeatingData -> StartState -> Shape -> Float -> Maybe Int
getHeatingTime data state shape thickness =
    let
        maxThickness = getMaxThickness data state shape

        -- The slider gives us exact table values, but safe to keep this logic
        safeThickness = round thickness
        
        table =
            case state of
                Thawed -> data.thawed
                Frozen -> data.frozen
        
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


-- VIEW


view : HeatingData -> HeatingStrings -> AppStrings -> Model -> Html Msg
view data t appT model =
    div [ class "max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-sm" ]
        [ h2 [ class "text-2xl font-bold mb-6 text-gray-800 border-b pb-2" ]
            [ text t.title ]
        
        , div [ class "grid grid-cols-1 md:grid-cols-2 gap-8" ]
            [ -- Input Section
              div [ class "space-y-6" ]
                [ viewStateSelector t model.startState
                , viewShapeSelector t model.shape
                , viewThicknessSlider data t model
                ]
            
            -- Result Section
            , div [ class "bg-indigo-50 rounded-lg p-6 flex flex-col justify-center items-center text-center" ]
                [ h3 [ class "text-lg font-medium text-indigo-800 mb-2" ] [ text t.resultHeader ]
                , viewResult data t model
                ]
            ]
        ]


viewStateSelector : HeatingStrings -> StartState -> Html Msg
viewStateSelector t selected =
    div []
        [ label [ class "block text-sm font-medium text-gray-700 mb-2" ] [ text t.startState ]
        , div [ class "flex rounded-md shadow-sm" ]
            [ stateButton t.thawed Thawed selected "rounded-l-md"
            , stateButton t.frozen Frozen selected "rounded-r-md"
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


viewShapeSelector : HeatingStrings -> Shape -> Html Msg
viewShapeSelector t selected =
    div []
        [ label [ class "block text-sm font-medium text-gray-700 mb-2" ] [ text t.shape ]
        , div [ class "grid grid-cols-1 gap-3 sm:grid-cols-3" ]
            [ shapeButton t.slab Slab selected t.slabDesc
            , shapeButton t.cylinder Cylinder selected t.cylinderDesc
            , shapeButton t.sphere Sphere selected t.sphereDesc
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


viewThicknessSlider : HeatingData -> HeatingStrings -> Model -> Html Msg
viewThicknessSlider data t model =
    let
        maxT = getMaxThickness data model.startState model.shape
        
        table = 
            case model.startState of
                Thawed -> data.thawed
                Frozen -> data.frozen

        allThicknesses = 
            table
                |> List.map (.thickness >> toFloat)
        
        allowed = 
            List.filter (\thickness -> thickness <= toFloat maxT) allThicknesses

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
        , label = t.thickness
        , formatter = formatter
        }


viewResult : HeatingData -> HeatingStrings -> Model -> Html Msg
viewResult data t model =
    let
        result =
            getHeatingTime data model.startState model.shape model.thicknessInput
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
                , span [ class "text-sm text-indigo-600 mt-2 block" ] [ text t.resultSuffix ]
                ]

        Nothing ->
            p [ class "text-red-600 font-medium" ] [ text t.errorThickness ]
