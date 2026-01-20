module Translations exposing (..)

import Json.Decode as Decode exposing (Decoder, string, field, map2, map3, map4, map5, map6)

type alias Translations =
    { app : AppStrings
    , tabs : TabsStrings
    , heating : HeatingStrings
    , pasteurization : PasteurizationStrings
    , rapidChilling : RapidChillingStrings
    , brine : BrineStrings
    , doneness : DonenessStrings
    , shelfLife : ShelfLifeStrings
    }

type alias AppStrings =
    { title : String
    , subtitle : String
    , footer : String
    , min : String
    , max : String
    }

type alias TabsStrings =
    { pasteurization : String
    , heating : String
    , rapidChilling : String
    , brine : String
    , doneness : String
    , shelfLife : String
    }

type alias HeatingStrings =
    { title : String
    , startState : String
    , thawed : String
    , frozen : String
    , shape : String
    , slab : String
    , cylinder : String
    , sphere : String
    , slabDesc : String
    , cylinderDesc : String
    , sphereDesc : String
    , thickness : String
    , resultHeader : String
    , resultSuffix : String
    , errorThickness : String
    }

type alias PasteurizationStrings =
    { title : String
    , protein : String
    , meat : String
    , poultry : String
    , leanFish : String
    , fattyFish : String
    , thickness : String
    , temp : String
    , safetyBuffer : String
    , safetyDesc : String
    , resultHeader : String
    , doubled : String
    , errorThickness : String
    , errorTemp : String
    }

type alias RapidChillingStrings =
    { title : String
    , shape : String
    , thickness : String
    , resultHeader : String
    , resultSuffix : String
    , errorThickness : String
    }

type alias BrineStrings =
    { title : String
    , protein : String
    , porkPoultry : String
    , brisket : String
    , units : String
    , metric : String
    , imperial : String
    , weightInput : String
    , resultHeader : String
    , salt : String
    , sugar : String
    , error : String
    }

type alias DonenessStrings =
    { title : String
    , protein : String
    , meat : String
    , fish : String
    , beef : DonenessBeef
    , fishDesc : DonenessFish
    }

type alias DonenessBeef =
    { very_rare : NameDesc
    , rare : NameDesc
    , medium_rare : NameDesc
    , medium : NameDesc
    }

type alias DonenessFish =
    { rare : NameDesc
    , medium_rare : NameDesc
    , medium : NameDesc
    }

type alias NameDesc =
    { name : String
    , desc : String
    }

type alias ShelfLifeStrings =
    { title : String
    , temp : String
    , resultHeader : String
    , suffix : String
    , error : String
    }

-- DECODER

translationsDecoder : Decoder Translations
translationsDecoder =
    Decode.map8 Translations
        (field "app" appDecoder)
        (field "tabs" tabsDecoder)
        (field "heating" heatingDecoder)
        (field "pasteurization" pasteurizationDecoder)
        (field "rapidChilling" rapidChillingDecoder)
        (field "brine" brineDecoder)
        (field "doneness" donenessDecoder)
        (field "shelfLife" shelfLifeDecoder)

appDecoder : Decoder AppStrings
appDecoder =
    map5 AppStrings
        (field "title" string)
        (field "subtitle" string)
        (field "footer" string)
        (field "min" string)
        (field "max" string)

tabsDecoder : Decoder TabsStrings
tabsDecoder =
    map6 TabsStrings
        (field "pasteurization" string)
        (field "heating" string)
        (field "rapidChilling" string)
        (field "brine" string)
        (field "doneness" string)
        (field "shelfLife" string)

heatingDecoder : Decoder HeatingStrings
heatingDecoder =
    Decode.succeed HeatingStrings
        |> required "title" string
        |> required "startState" string
        |> required "thawed" string
        |> required "frozen" string
        |> required "shape" string
        |> required "slab" string
        |> required "cylinder" string
        |> required "sphere" string
        |> required "slabDesc" string
        |> required "cylinderDesc" string
        |> required "sphereDesc" string
        |> required "thickness" string
        |> required "resultHeader" string
        |> required "resultSuffix" string
        |> required "errorThickness" string

pasteurizationDecoder : Decoder PasteurizationStrings
pasteurizationDecoder =
    Decode.succeed PasteurizationStrings
        |> required "title" string
        |> required "protein" string
        |> required "meat" string
        |> required "poultry" string
        |> required "leanFish" string
        |> required "fattyFish" string
        |> required "thickness" string
        |> required "temp" string
        |> required "safetyBuffer" string
        |> required "safetyDesc" string
        |> required "resultHeader" string
        |> required "doubled" string
        |> required "errorThickness" string
        |> required "errorTemp" string

rapidChillingDecoder : Decoder RapidChillingStrings
rapidChillingDecoder =
    map6 RapidChillingStrings
        (field "title" string)
        (field "shape" string)
        (field "thickness" string)
        (field "resultHeader" string)
        (field "resultSuffix" string)
        (field "errorThickness" string)

brineDecoder : Decoder BrineStrings
brineDecoder =
    Decode.succeed BrineStrings
        |> required "title" string
        |> required "protein" string
        |> required "porkPoultry" string
        |> required "brisket" string
        |> required "units" string
        |> required "metric" string
        |> required "imperial" string
        |> required "weightInput" string
        |> required "resultHeader" string
        |> required "salt" string
        |> required "sugar" string
        |> required "error" string

donenessDecoder : Decoder DonenessStrings
donenessDecoder =
    map6 DonenessStrings
        (field "title" string)
        (field "protein" string)
        (field "meat" string)
        (field "fish" string)
        (field "beef" donenessBeefDecoder)
        (field "fishDesc" donenessFishDecoder)

donenessBeefDecoder : Decoder DonenessBeef
donenessBeefDecoder =
    map4 DonenessBeef
        (field "very_rare" nameDescDecoder)
        (field "rare" nameDescDecoder)
        (field "medium_rare" nameDescDecoder)
        (field "medium" nameDescDecoder)

donenessFishDecoder : Decoder DonenessFish
donenessFishDecoder =
    map3 DonenessFish
        (field "rare" nameDescDecoder)
        (field "medium_rare" nameDescDecoder)
        (field "medium" nameDescDecoder)

nameDescDecoder : Decoder NameDesc
nameDescDecoder =
    map2 NameDesc
        (field "name" string)
        (field "desc" string)

shelfLifeDecoder : Decoder ShelfLifeStrings
shelfLifeDecoder =
    map5 ShelfLifeStrings
        (field "title" string)
        (field "temp" string)
        (field "resultHeader" string)
        (field "suffix" string)
        (field "error" string)

-- Helper for large records
required : String -> Decoder a -> Decoder (a -> b) -> Decoder b
required key valDecoder decoder =
    map2 (|>) (field key valDecoder) decoder
