module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Data exposing (Data)

import Calculators.Heating
import Calculators.Pasteurization
import Calculators.RapidChilling
import Calculators.BrineMarinade
import Calculators.Doneness
import Calculators.ShelfLife


-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type Tab
    = Pasteurization
    | Heating
    | RapidChilling
    | BrineMarinade
    | Doneness
    | ShelfLife


type Status
    = Loading
    | Failed Http.Error
    | Loaded Data


type alias Model =
    { activeTab : Tab
    , status : Status
    , heating : Calculators.Heating.Model
    , pasteurization : Calculators.Pasteurization.Model
    , rapidChilling : Calculators.RapidChilling.Model
    , brineMarinade : Calculators.BrineMarinade.Model
    , doneness : Calculators.Doneness.Model
    , shelfLife : Calculators.ShelfLife.Model
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { activeTab = Pasteurization
      , status = Loading
      , heating = Calculators.Heating.init
      , pasteurization = Calculators.Pasteurization.init
      , rapidChilling = Calculators.RapidChilling.init
      , brineMarinade = Calculators.BrineMarinade.init
      , doneness = Calculators.Doneness.init
      , shelfLife = Calculators.ShelfLife.init
      }
    , Http.get
        { url = "data.json"
        , expect = Http.expectJson GotData Data.dataDecoder
        }
    )



-- UPDATE


type Msg
    = SelectTab Tab
    | GotData (Result Http.Error Data)
    | HeatingMsg Calculators.Heating.Msg
    | PasteurizationMsg Calculators.Pasteurization.Msg
    | RapidChillingMsg Calculators.RapidChilling.Msg
    | BrineMarinadeMsg Calculators.BrineMarinade.Msg
    | DonenessMsg Calculators.Doneness.Msg
    | ShelfLifeMsg Calculators.ShelfLife.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectTab tab ->
            ( { model | activeTab = tab }, Cmd.none )

        GotData result ->
            case result of
                Ok data ->
                    ( { model | status = Loaded data }, Cmd.none )

                Err error ->
                    ( { model | status = Failed error }, Cmd.none )

        HeatingMsg subMsg ->
            case model.status of
                Loaded data ->
                    ( { model | heating = Calculators.Heating.update data.heating subMsg model.heating }, Cmd.none )
                _ ->
                    ( model, Cmd.none )

        PasteurizationMsg subMsg ->
            ( { model | pasteurization = Calculators.Pasteurization.update subMsg model.pasteurization }, Cmd.none )

        RapidChillingMsg subMsg ->
            case model.status of
                Loaded data ->
                    ( { model | rapidChilling = Calculators.RapidChilling.update data.rapidChilling subMsg model.rapidChilling }, Cmd.none )
                _ ->
                    ( model, Cmd.none )

        BrineMarinadeMsg subMsg ->
            ( { model | brineMarinade = Calculators.BrineMarinade.update subMsg model.brineMarinade }, Cmd.none )

        DonenessMsg subMsg ->
            ( { model | doneness = Calculators.Doneness.update subMsg model.doneness }, Cmd.none )

        ShelfLifeMsg subMsg ->
            ( { model | shelfLife = Calculators.ShelfLife.update subMsg model.shelfLife }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "min-h-screen bg-gray-50 flex flex-col font-sans" ]
        [ viewHeader
        , case model.status of
            Loading ->
                viewLoading

            Failed error ->
                viewError error

            Loaded data ->
                div [ class "flex-grow flex flex-col" ]
                    [ viewTabs model
                    , viewContent data model
                    ]
        , viewFooter
        ]


viewHeader : Html Msg
viewHeader =
    header [ class "bg-white shadow-sm sticky top-0 z-10" ]
        [ div [ class "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between" ]
            [ div [ class "flex items-center" ]
                [ h1 [ class "text-xl font-bold text-gray-900 tracking-tight" ]
                    [ text "Sous Vide Calculator" ]
                , span [ class "ml-3 px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 hidden sm:inline-block" ]
                    [ text "Baldwin Model" ]
                ]
            ]
        ]


viewLoading : Html Msg
viewLoading =
    div [ class "flex-grow flex items-center justify-center" ]
        [ div [ class "text-center" ]
            [ div [ class "inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-indigo-600 mb-4" ] []
            , p [ class "text-gray-500" ] [ text "Loading data..." ]
            ]
        ]


viewError : Http.Error -> Html Msg
viewError error =
    let
        errorMsg =
            case error of
                Http.BadUrl url -> "Bad URL: " ++ url
                Http.Timeout -> "Timeout"
                Http.NetworkError -> "Network Error"
                Http.BadStatus status -> "Bad Status: " ++ String.fromInt status
                Http.BadBody body -> "Bad Body: " ++ body
    in
    div [ class "flex-grow flex items-center justify-center p-4" ]
        [ div [ class "bg-red-50 p-4 rounded-lg text-center" ]
            [ h3 [ class "text-red-800 font-bold mb-2" ] [ text "Failed to load data" ]
            , p [ class "text-red-600" ] [ text errorMsg ]
            ]
        ]


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


viewContent : Data -> Model -> Html Msg
viewContent data model =
    main_ [ class "flex-grow max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-8" ]
        [ case model.activeTab of
            Heating ->
                Html.map HeatingMsg (Calculators.Heating.view data.heating model.heating)

            Pasteurization ->
                Html.map PasteurizationMsg (Calculators.Pasteurization.view data.pasteurization model.pasteurization)

            RapidChilling ->
                Html.map RapidChillingMsg (Calculators.RapidChilling.view data.rapidChilling model.rapidChilling)

            BrineMarinade ->
                Html.map BrineMarinadeMsg (Calculators.BrineMarinade.view data.brine model.brineMarinade)

            Doneness ->
                Html.map DonenessMsg (Calculators.Doneness.view data.doneness model.doneness)

            ShelfLife ->
                Html.map ShelfLifeMsg (Calculators.ShelfLife.view data.shelfLife model.shelfLife)
        ]


viewFooter : Html msg
viewFooter =
    footer [ class "bg-white border-t border-gray-200 mt-auto" ]
        [ div [ class "max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8" ]
            [ p [ class "text-center text-sm text-gray-500" ]
                [ text "Based on 'A Practical Guide to Sous Vide Cooking' by Dr. Douglas Baldwin." ]
            ]
        ]