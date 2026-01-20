module Calculators.Doneness exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Data exposing (DonenessData, DonenessLevel)


-- MODEL


type Protein
    = Beef
    | Fish


type alias Model =
    { protein : Protein
    }


init : Model
init =
    { protein = Beef
    }


type Msg
    = SetProtein Protein


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetProtein protein ->
            { model | protein = protein }



-- DATA


getDonenessLevels : DonenessData -> Protein -> List DonenessLevel
getDonenessLevels data protein =
    case protein of
        Beef -> data.beef
        Fish -> data.fish


-- VIEW


view : DonenessData -> Model -> Html Msg
view data model =
    div [ class "max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-sm" ]
        [ h2 [ class "text-2xl font-bold mb-6 text-gray-800 border-b pb-2" ]
            [ text "Doneness & Texture Visualizer" ]
        
        , div [ class "mb-8" ]
            [ viewProteinSelector model.protein
            ]
        
        , div [ class "grid grid-cols-1 md:grid-cols-3 gap-6" ]
            (List.map viewDonenessCard (getDonenessLevels data model.protein))
        ]


viewProteinSelector : Protein -> Html Msg
viewProteinSelector selected =
    div []
        [ label [ class "block text-sm font-medium text-gray-700 mb-2" ] [ text "Protein Type" ]
        , div [ class "flex rounded-md shadow-sm max-w-sm" ]
            [ proteinButton "Meat (Beef/Lamb)" Beef selected "rounded-l-md"
            , proteinButton "Fish" Fish selected "rounded-r-md"
            ]
        ]


proteinButton : String -> Protein -> Protein -> String -> Html Msg
proteinButton labelStr protein selected roundedClass =
    let
        isSelected = protein == selected
        baseClasses = "flex-1 px-4 py-2 text-sm font-medium border focus:z-10 focus:ring-2 focus:ring-red-500"
        colors =
            if isSelected then
                "bg-red-600 text-white border-red-600"
            else
                "bg-white text-gray-700 border-gray-300 hover:bg-gray-50"
    in
    button
        [ type_ "button"
        , class (baseClasses ++ " " ++ colors ++ " " ++ roundedClass)
        , onClick (SetProtein protein)
        ]
        [ text labelStr ]


viewDonenessCard : DonenessLevel -> Html Msg
viewDonenessCard level =
    let
        tempString =
            String.fromFloat level.tempC ++ "°C / " ++ String.fromInt level.tempF ++ "°F"
    in
    div [ class "flex flex-col rounded-lg shadow overflow-hidden border border-gray-200" ]
        [ div [ class ("px-6 py-4 flex-grow flex flex-col items-center justify-center text-center " ++ level.color) ]
            [ h3 [ class "text-lg font-bold" ] [ text level.name ]
            , span [ class "text-3xl font-extrabold mt-2" ] [ text tempString ]
            ]
        , div [ class "px-6 py-4 bg-gray-50 flex-grow" ]
            [ p [ class "text-sm text-gray-600 text-center" ] [ text level.desc ]
            ]
        ]