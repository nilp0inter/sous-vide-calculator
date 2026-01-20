module Slider exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Round

{-| A slider component that snaps to specific allowed values.
    
    value: The current selected value (must be one of the allowed values, or close to it).
    allowedValues: A List of valid Float values.
    toMsg: Function to convert the new Float value into a Msg.
    label: The label for the input.
    formatter: Function to format the value for display (e.g. "25 mm / 1.0 in").
-}
view : 
    { value : Float
    , allowedValues : List Float
    , toMsg : Float -> msg
    , label : String
    , formatter : Float -> String
    } 
    -> Html msg
view props =
    let
        sortedValues = List.sort props.allowedValues
        
        -- Find the index of the current value in the allowed list
        currentIndex = 
            sortedValues
                |> List.indexedMap Tuple.pair
                |> List.filter (\(_, v) -> v == props.value)
                |> List.head
                |> Maybe.map Tuple.first
                |> Maybe.withDefault 0

        maxIndex = List.length sortedValues - 1
        
        realMin = List.head sortedValues |> Maybe.withDefault 0
        realMax = List.reverse sortedValues |> List.head |> Maybe.withDefault 0

        -- Handle slider change
        handleInput str =
            String.toInt str
                |> Maybe.andThen (\idx -> 
                    sortedValues 
                        |> List.drop idx 
                        |> List.head
                )
                |> Maybe.map props.toMsg
                |> Maybe.withDefault (props.toMsg props.value)

    in
    div [ class "w-full" ]
        [ div [ class "flex justify-between items-center mb-2" ]
            [ label [ class "block text-sm font-medium text-gray-700" ] [ text props.label ]
            , span [ class "text-sm font-bold text-indigo-600 bg-indigo-50 px-2 py-1 rounded" ] 
                [ text (props.formatter props.value) ]
            ]
        , input
            [ type_ "range"
            , Html.Attributes.min "0"
            , Html.Attributes.max (String.fromInt maxIndex)
            , value (String.fromInt currentIndex)
            , step "1"
            , attribute "aria-valuemin" (String.fromFloat realMin)
            , attribute "aria-valuemax" (String.fromFloat realMax)
            , attribute "aria-valuenow" (String.fromFloat props.value)
            , attribute "aria-valuetext" (props.formatter props.value)
            , attribute "aria-label" props.label
            , onInput handleInput
            , class "w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-indigo-600"
            ]
            []
        , div [ class "flex justify-between text-xs text-gray-400 mt-1" ]
            [ span [] [ text "Min" ]
            , span [] [ text "Max" ]
            ]
        ]
