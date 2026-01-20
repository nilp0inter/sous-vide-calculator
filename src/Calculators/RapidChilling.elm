module Calculators.RapidChilling exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Slider
import Round
import Data exposing (ChillingRow)
import Translations exposing (RapidChillingStrings, HeatingStrings, AppStrings)


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


update : List ChillingRow -> Msg -> Model -> Model
update data msg model =
    case msg of
        SetShape shape ->
            let
                maxT = getMaxThickness data shape
                newThickness = Basics.min model.thicknessInput (toFloat maxT)
            in
            { model | shape = shape, thicknessInput = newThickness }

        SetThickness val ->
            { model | thicknessInput = val }


getMaxThickness : List ChillingRow -> Shape -> Int
getMaxThickness data shape =
    let
        hasValue row =
            case shape of
                Slab -> row.slab /= Nothing
                Cylinder -> row.cylinder /= Nothing
                Sphere -> row.sphere /= Nothing
    in
    data
        |> List.filter hasValue
        |> List.map .thickness
        |> List.maximum
        |> Maybe.withDefault 0


-- DATA


{-| Returns cooling time in minutes.
    Logic: Round thickness UP to nearest 5mm in table.
-}
getCoolingTime : List ChillingRow -> Shape -> Float -> Maybe Int
getCoolingTime data shape thickness =
    let
        maxThickness = getMaxThickness data shape

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
        data
            |> List.filter (\row -> row.thickness == safeThickness)
            |> List.head
            |> Maybe.andThen getColumn


-- VIEW


view : List ChillingRow -> RapidChillingStrings -> HeatingStrings -> AppStrings -> Model -> Html Msg
view data t heatingT appT model =
    div [ class "max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-sm" ]
        [ h2 [ class "text-2xl font-bold mb-6 text-gray-800 border-b pb-2" ]
            [ text t.title ]
        
        , div [ class "grid grid-cols-1 md:grid-cols-2 gap-8" ]
            [ -- Input Section
              div [ class "space-y-6" ]
                [ viewShapeSelector t heatingT model.shape
                , viewThicknessSlider data t model
                ]
            
            -- Result Section
            , div [ class "bg-emerald-50 rounded-lg p-6 flex flex-col justify-center items-center text-center", attribute "aria-live" "polite" ]
                [ h3 [ class "text-lg font-medium text-emerald-800 mb-2" ] [ text t.resultHeader ]
                , viewResult data t model
                ]
            ]
        ]


viewShapeSelector : RapidChillingStrings -> HeatingStrings -> Shape -> Html Msg
viewShapeSelector t heatingT selected =
    div [ attribute "role" "radiogroup", attribute "aria-labelledby" "rc-shape-label" ]
        [ label [ id "rc-shape-label", class "block text-sm font-medium text-gray-700 mb-2" ] [ text t.shape ]
        , div [ class "grid grid-cols-1 gap-3 sm:grid-cols-3" ]
            [ shapeButton heatingT.slab Slab selected heatingT.slabDesc
            , shapeButton heatingT.cylinder Cylinder selected heatingT.cylinderDesc
            , shapeButton heatingT.sphere Sphere selected heatingT.sphereDesc
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
        , attribute "role" "radio"
        , attribute "aria-checked" (if isSelected then "true" else "false")
        ]
        [ span [ class "block font-bold" ] [ text labelStr ]
        , span [ class ("block text-xs mt-1 " ++ if isSelected then "text-emerald-500" else "text-gray-500") ] [ text description ]
        ]


viewThicknessSlider : List ChillingRow -> RapidChillingStrings -> Model -> Html Msg
viewThicknessSlider data t model =
    let
        maxT = getMaxThickness data model.shape
        
        allThicknesses = 
            data
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


viewResult : List ChillingRow -> RapidChillingStrings -> Model -> Html Msg
viewResult data t model =
    let
        result =
            getCoolingTime data model.shape model.thicknessInput
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
                , span [ class "text-sm text-emerald-600 mt-2 block" ] [ text t.resultSuffix ]
                ]

        Nothing ->
            p [ class "text-red-600 font-medium" ] [ text t.errorThickness ]