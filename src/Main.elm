port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Data exposing (Data)
import Translations exposing (Translations)

import Calculators.Heating
import Calculators.Pasteurization
import Calculators.RapidChilling
import Calculators.BrineMarinade
import Calculators.Doneness
import Calculators.ShelfLife
import Introduction


-- PORTS

port onHashChange : (String -> msg) -> Sub msg


-- MAIN

type alias Flags =
    { lang : String
    , hash : String
    }

main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


-- MODEL


type Tab
    = Introduction
    | BrineMarinade
    | Doneness
    | Heating
    | Pasteurization
    | RapidChilling
    | ShelfLife


type Status
    = Loading
    | Failed Http.Error
    | Loaded Data


type Language
    = En
    | Es
    | Fr
    | De
    | Pt
    | Fi


type alias Model =
    { activeTab : Tab
    , status : Status
    , translations : Maybe Translations
    , currentLanguage : Language
    , error : Maybe Http.Error
    , heating : Calculators.Heating.Model
    , pasteurization : Calculators.Pasteurization.Model
    , rapidChilling : Calculators.RapidChilling.Model
    , brineMarinade : Calculators.BrineMarinade.Model
    , doneness : Calculators.Doneness.Model
    , shelfLife : Calculators.ShelfLife.Model
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        defaultLang =
            if String.startsWith "es" (String.toLower flags.lang) then
                Es
            else if String.startsWith "fr" (String.toLower flags.lang) then
                Fr
            else if String.startsWith "de" (String.toLower flags.lang) then
                De
            else if String.startsWith "pt" (String.toLower flags.lang) then
                Pt
            else if String.startsWith "fi" (String.toLower flags.lang) then
                Fi
            else
                En
        
        initialTab =
            hashToTab flags.hash
    in
    ( { activeTab = initialTab
      , status = Loading
      , translations = Nothing
      , currentLanguage = defaultLang
      , error = Nothing
      , heating = Calculators.Heating.init
      , pasteurization = Calculators.Pasteurization.init
      , rapidChilling = Calculators.RapidChilling.init
      , brineMarinade = Calculators.BrineMarinade.init
      , doneness = Calculators.Doneness.init
      , shelfLife = Calculators.ShelfLife.init
      }
    , Cmd.batch
        [ Http.get
            { url = "data.json"
            , expect = Http.expectJson GotData Data.dataDecoder
            }
        , fetchTranslations defaultLang
        ]
    )


fetchTranslations : Language -> Cmd Msg
fetchTranslations lang =
    Http.get
        { url = languageToFilename lang
        , expect = Http.expectJson GotTranslations Translations.translationsDecoder
        }


languageToFilename : Language -> String
languageToFilename lang =
    case lang of
        En -> "en.json"
        Es -> "es.json"
        Fr -> "fr.json"
        De -> "de.json"
        Pt -> "pt.json"
        Fi -> "fi.json"


-- ROUTING HELPERS

tabToHash : Tab -> String
tabToHash tab =
    case tab of
        Introduction -> "introduction"
        BrineMarinade -> "brine"
        Doneness -> "doneness"
        Heating -> "heating"
        Pasteurization -> "pasteurization"
        RapidChilling -> "chilling"
        ShelfLife -> "shelf-life"

hashToTab : String -> Tab
hashToTab hash =
    let
        cleanHash =
            if String.startsWith "#" hash then
                String.dropLeft 1 hash
            else
                hash
    in
    case cleanHash of
        "brine" -> BrineMarinade
        "doneness" -> Doneness
        "heating" -> Heating
        "pasteurization" -> Pasteurization
        "chilling" -> RapidChilling
        "shelf-life" -> ShelfLife
        "introduction" -> Introduction
        _ -> Introduction


-- UPDATE


type Msg
    = SelectTab Tab
    | SetLanguage String
    | GotData (Result Http.Error Data)
    | GotTranslations (Result Http.Error Translations)
    | HeatingMsg Calculators.Heating.Msg
    | PasteurizationMsg Calculators.Pasteurization.Msg
    | RapidChillingMsg Calculators.RapidChilling.Msg
    | BrineMarinadeMsg Calculators.BrineMarinade.Msg
    | DonenessMsg Calculators.Doneness.Msg
    | ShelfLifeMsg Calculators.ShelfLife.Msg
    | HashChanged String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectTab tab ->
            ( { model | activeTab = tab }, Cmd.none )

        SetLanguage langStr ->
            let
                newLang =
                    case langStr of
                        "es" -> Es
                        "fr" -> Fr
                        "de" -> De
                        "pt" -> Pt
                        "fi" -> Fi
                        _ -> En
            in
            if newLang == model.currentLanguage then
                ( model, Cmd.none )
            else
                ( { model | currentLanguage = newLang, translations = Nothing }
                , fetchTranslations newLang
                )

        GotData result ->
            case result of
                Ok data ->
                    ( { model | status = Loaded data }, Cmd.none )

                Err error ->
                    ( { model | status = Failed error }, Cmd.none )

        GotTranslations result ->
            case result of
                Ok translations ->
                    ( { model | translations = Just translations }, Cmd.none )

                Err error ->
                    ( { model | error = Just error }, Cmd.none )

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

        HashChanged hash ->
            ( { model | activeTab = hashToTab hash }, Cmd.none )



-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ =
    onHashChange HashChanged


-- VIEW


view : Model -> Html Msg
view model =
    case (model.status, model.translations) of
        (Loaded data, Just translations) ->
            viewLoaded data translations model

        (Failed error, _) ->
            viewError error
        
        (_, _) ->
            if model.error /= Nothing then
                 viewError (Maybe.withDefault Http.Timeout model.error)
            else
                 viewLoading


viewLoaded : Data -> Translations -> Model -> Html Msg
viewLoaded data translations model =
    div [ class "min-h-screen bg-gray-50 flex flex-col font-sans" ]
        [ viewHeader translations model.currentLanguage
        , viewTabs translations model
        , viewContent data translations model
        , viewFooter translations
        ]


viewHeader : Translations -> Language -> Html Msg
viewHeader t currentLang =
    header [ class "bg-white shadow-sm sticky top-0 z-10" ]
        [ div [ class "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between" ]
            [ div [ class "flex items-center" ]
                [ h1 [ class "text-xl font-bold text-gray-900 tracking-tight" ]
                    [ text t.app.title ]
                , span [ class "ml-3 px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 hidden sm:inline-block" ]
                    [ text t.app.subtitle ]
                ]
            , viewLanguageSelector currentLang
            ]
        ]


viewLanguageSelector : Language -> Html Msg
viewLanguageSelector currentLang =
    div [ class "relative" ]
        [ select
            [ onInput SetLanguage
            , attribute "aria-label" "Select Language"
            , class "block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md"
            ]
            [ option [ value "de", selected (currentLang == De) ] [ text "Deutsch" ]
            , option [ value "en", selected (currentLang == En) ] [ text "English" ]
            , option [ value "es", selected (currentLang == Es) ] [ text "Español" ]
            , option [ value "fr", selected (currentLang == Fr) ] [ text "Français" ]
            , option [ value "pt", selected (currentLang == Pt) ] [ text "Português" ]
            , option [ value "fi", selected (currentLang == Fi) ] [ text "Suomi" ]
            ]
        ]


viewLoading : Html Msg
viewLoading =
    div [ class "min-h-screen flex items-center justify-center bg-gray-50", attribute "role" "status" ]
        [ div [ class "text-center" ]
            [ div [ class "inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-indigo-600 mb-4" ] []
            , p [ class "text-gray-500" ] [ text "Loading resources..." ]
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
    div [ class "min-h-screen flex items-center justify-center p-4 bg-gray-50" ]
        [ div [ class "bg-red-50 p-4 rounded-lg text-center shadow" ]
            [ h3 [ class "text-red-800 font-bold mb-2" ] [ text "Failed to load resources" ]
            , p [ class "text-red-600" ] [ text errorMsg ]
            ]
        ]


viewTabs : Translations -> Model -> Html Msg
viewTabs t model =
    div [ class "bg-white border-b border-gray-200 overflow-x-auto scrollbar-hide" ]
        [ div [ class "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8" ]
            [ nav [ class "-mb-px flex space-x-6 sm:space-x-8", attribute "role" "tablist", attribute "aria-label" "Tabs" ]
                [ tabButton Introduction model.activeTab t.tabs.introduction
                , tabButton BrineMarinade model.activeTab t.tabs.brine
                , tabButton Doneness model.activeTab t.tabs.doneness
                , tabButton Heating model.activeTab t.tabs.heating
                , tabButton Pasteurization model.activeTab t.tabs.pasteurization
                , tabButton RapidChilling model.activeTab t.tabs.rapidChilling
                , tabButton ShelfLife model.activeTab t.tabs.shelfLife
                ]
            ]
        ]


tabButton : Tab -> Tab -> String -> Html Msg
tabButton tab currentTab label =
    let
        isActive =
            tab == currentTab

        baseClasses =
            "whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm transition-colors duration-200 no-underline"

        stateClasses =
            if isActive then
                "border-blue-500 text-blue-600"
            else
                "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
    in
    a
        [ href ("#" ++ tabToHash tab)
        , onClick (SelectTab tab)
        , class (baseClasses ++ " " ++ stateClasses ++ " cursor-pointer")
        , attribute "role" "tab"
        , attribute "aria-selected" (if isActive then "true" else "false")
        ]
        [ text label ]


viewContent : Data -> Translations -> Model -> Html Msg
viewContent data t model =
    main_ [ class "flex-grow max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-8" ]
        [ case model.activeTab of
            Introduction ->
                Introduction.view t.introduction

            BrineMarinade ->
                Html.map BrineMarinadeMsg (Calculators.BrineMarinade.view data.brine t.brine model.brineMarinade)

            Doneness ->
                Html.map DonenessMsg (Calculators.Doneness.view data.doneness t.doneness model.doneness)

            Heating ->
                Html.map HeatingMsg (Calculators.Heating.view data.heating t.heating t.app model.heating)

            Pasteurization ->
                Html.map PasteurizationMsg (Calculators.Pasteurization.view data.pasteurization t.pasteurization t.app model.pasteurization)

            RapidChilling ->
                Html.map RapidChillingMsg (Calculators.RapidChilling.view data.rapidChilling t.rapidChilling t.heating t.app model.rapidChilling)

            ShelfLife ->
                Html.map ShelfLifeMsg (Calculators.ShelfLife.view data.shelfLife t.shelfLife t.app model.shelfLife)
        ]


viewFooter : Translations -> Html msg
viewFooter t =
    footer [ class "bg-white border-t border-gray-200 mt-auto" ]
        [ div [ class "max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8" ]
            [ p [ class "text-center text-sm text-gray-500" ]
                [ text t.app.footer ]
            ]
        ]
