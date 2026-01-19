module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Calculators.Heating
import Calculators.Pasteurization
import Calculators.RapidChilling
import Calculators.BrineMarinade
import Calculators.Doneness
import Calculators.ShelfLife


-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }



-- MODEL


type UnitSystem
    = Metric
    | Imperial


type Tab
    = Pasteurization
    | Heating
    | RapidChilling
    | BrineMarinade
    | Doneness
    | ShelfLife


type alias Model =
    { activeTab : Tab
    , units : UnitSystem
    , heating : Calculators.Heating.Model
    , pasteurization : Calculators.Pasteurization.Model
    , rapidChilling : Calculators.RapidChilling.Model
    , brineMarinade : Calculators.BrineMarinade.Model
    , doneness : Calculators.Doneness.Model
    , shelfLife : Calculators.ShelfLife.Model
    }


init : Model
init =
    { activeTab = Pasteurization
    , units = Metric
    , heating = Calculators.Heating.init
    , pasteurization = Calculators.Pasteurization.init
    , rapidChilling = Calculators.RapidChilling.init
    , brineMarinade = Calculators.BrineMarinade.init
    , doneness = Calculators.Doneness.init
    , shelfLife = Calculators.ShelfLife.init
    }



-- UPDATE


type Msg
    = SelectTab Tab
    | SetUnits UnitSystem
    | HeatingMsg Calculators.Heating.Msg
    | PasteurizationMsg Calculators.Pasteurization.Msg
    | RapidChillingMsg Calculators.RapidChilling.Msg
    | BrineMarinadeMsg Calculators.BrineMarinade.Msg
    | DonenessMsg Calculators.Doneness.Msg
    | ShelfLifeMsg Calculators.ShelfLife.Msg


update : Msg -> Model -> Model
update msg model =
    case msg of
        SelectTab tab ->
            { model | activeTab = tab }

        SetUnits units ->
            { model | units = units }

        HeatingMsg subMsg ->
            { model | heating = Calculators.Heating.update subMsg model.heating }

        PasteurizationMsg subMsg ->
            { model | pasteurization = Calculators.Pasteurization.update subMsg model.pasteurization }

        RapidChillingMsg subMsg ->
            { model | rapidChilling = Calculators.RapidChilling.update subMsg model.rapidChilling }

        BrineMarinadeMsg subMsg ->
            { model | brineMarinade = Calculators.BrineMarinade.update subMsg model.brineMarinade }

        DonenessMsg subMsg ->
            { model | doneness = Calculators.Doneness.update subMsg model.doneness }

        ShelfLifeMsg subMsg ->
            { model | shelfLife = Calculators.ShelfLife.update subMsg model.shelfLife }



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "min-h-screen bg-gray-50 flex flex-col font-sans" ]
        [ viewHeader model
        , viewTabs model
        , viewContent model
        , viewFooter
        ]


viewHeader : Model -> Html Msg
viewHeader model =
    header [ class "bg-white shadow-sm sticky top-0 z-10" ]
        [ div [ class "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between" ]
            [ div [ class "flex items-center" ]
                [ h1 [ class "text-xl font-bold text-gray-900 tracking-tight" ]
                    [ text "Sous Vide Calculator" ]
                , span [ class "ml-3 px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 hidden sm:inline-block" ]
                    [ text "Baldwin Model" ]
                ]
            , viewUnitToggle model.units
            ]
        ]


viewUnitToggle : UnitSystem -> Html Msg
viewUnitToggle currentUnits =
    div [ class "flex bg-gray-200 rounded-lg p-1" ]
        [ unitButton Metric currentUnits "Metric"
        , unitButton Imperial currentUnits "Imperial"
        ]


unitButton : UnitSystem -> UnitSystem -> String -> Html Msg
unitButton units currentUnits label =
    let
        isActive =
            units == currentUnits

        activeClasses =
            if isActive then
                "bg-white shadow text-gray-900"
            else
                "text-gray-500 hover:text-gray-900"
    in
    button
        [ onClick (SetUnits units)
        , class ("px-3 py-1.5 rounded-md text-sm font-medium transition-all duration-200 " ++ activeClasses)
        ]
        [ text label ]


viewTabs : Model -> Html Msg
viewTabs model =
    div [ class "bg-white border-b border-gray-200 overflow-x-auto scrollbar-hide" ]
        [ div [ class "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8" ]
            [ nav [ class "-mb-px flex space-x-6 sm:space-x-8", attribute "aria-label" "Tabs" ]
                [ tabButton Pasteurization model.activeTab "Pasteurization"
                , tabButton Heating model.activeTab "Heating Time"
                , tabButton RapidChilling model.activeTab "Rapid Chilling"
                , tabButton BrineMarinade model.activeTab "Brine & Marinade"
                , tabButton Doneness model.activeTab "Doneness"
                , tabButton ShelfLife model.activeTab "Shelf Life"
                ]
            ]
        ]


tabButton : Tab -> Tab -> String -> Html Msg
tabButton tab currentTab label =
    let
        isActive =
            tab == currentTab

        baseClasses =
            "whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm transition-colors duration-200"

        stateClasses =
            if isActive then
                "border-blue-500 text-blue-600"
            else
                "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
    in
    button
        [ onClick (SelectTab tab)
        , class (baseClasses ++ " " ++ stateClasses)
        ]
        [ text label ]


viewContent : Model -> Html Msg
viewContent model =
    let
        isMetric = model.units == Metric
    in
    main_ [ class "flex-grow max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-8" ]
        [ case model.activeTab of
            Heating ->
                Html.map HeatingMsg (Calculators.Heating.view isMetric model.heating)

            Pasteurization ->
                Html.map PasteurizationMsg (Calculators.Pasteurization.view isMetric model.pasteurization)

            RapidChilling ->
                Html.map RapidChillingMsg (Calculators.RapidChilling.view isMetric model.rapidChilling)

            BrineMarinade ->
                Html.map BrineMarinadeMsg (Calculators.BrineMarinade.view isMetric model.brineMarinade)

            Doneness ->
                Html.map DonenessMsg (Calculators.Doneness.view isMetric model.doneness)

            ShelfLife ->
                Html.map ShelfLifeMsg (Calculators.ShelfLife.view isMetric model.shelfLife)
        ]


viewFooter : Html msg
viewFooter =
    footer [ class "bg-white border-t border-gray-200 mt-auto" ]
        [ div [ class "max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8" ]
            [ p [ class "text-center text-sm text-gray-500" ]
                [ text "Based on 'A Practical Guide to Sous Vide Cooking' by Dr. Douglas Baldwin." ]
            ]
        ]