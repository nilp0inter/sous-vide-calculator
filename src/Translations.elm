module Translations exposing (..)

import Json.Decode as Decode exposing (Decoder, string, field, map2, map3, map4, map5, map6, map7)

type alias Translations =
    { app : AppStrings
    , tabs : TabsStrings
    , introduction : IntroductionStrings
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
    { introduction : String
    , pasteurization : String
    , heating : String
    , rapidChilling : String
    , brine : String
    , doneness : String
    , shelfLife : String
    }

type alias IntroductionStrings =
    { title : String
    , whatIsTitle : String
    , whatIsBody : String
    , threeStagesTitle : String
    , stage1Title : String
    , stage1Body : String
    , stage2Title : String
    , stage2Body : String
    , stage3Title : String
    , stage3Body : String
    , stage4Title : String
    , stage4Body : String
    , safetyNoteTitle : String
    , safetyNoteBody : String
    }

type alias HeatingStrings =
    { title : String
    , explanation : String
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
    , explanation : String
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
    , explanation : String
    , shape : String
    , thickness : String
    , resultHeader : String
    , resultSuffix : String
    , errorThickness : String
    }

type alias BrineStrings =
    { title : String
    , explanation : String
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
    , explanation : String
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
    , explanation : String
    , temp : String
    , resultHeader : String
    , suffix : String
    , error : String
    }

-- DECODER

translationsDecoder : Decoder Translations
translationsDecoder =
    Decode.succeed Translations
        |> required "app" appDecoder
        |> required "tabs" tabsDecoder
        |> required "introduction" introductionDecoder
        |> required "heating" heatingDecoder
        |> required "pasteurization" pasteurizationDecoder
        |> required "rapidChilling" rapidChillingDecoder
        |> required "brine" brineDecoder
        |> required "doneness" donenessDecoder
        |> required "shelfLife" shelfLifeDecoder

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
    map7 TabsStrings
        (field "introduction" string)
        (field "pasteurization" string)
        (field "heating" string)
        (field "rapidChilling" string)
        (field "brine" string)
        (field "doneness" string)
        (field "shelfLife" string)

introductionDecoder : Decoder IntroductionStrings
introductionDecoder =
    Decode.succeed IntroductionStrings
        |> required "title" string
        |> required "whatIsTitle" string
        |> required "whatIsBody" string
        |> required "threeStagesTitle" string
        |> required "stage1Title" string
        |> required "stage1Body" string
        |> required "stage2Title" string
        |> required "stage2Body" string
        |> required "stage3Title" string
        |> required "stage3Body" string
        |> required "stage4Title" string
        |> required "stage4Body" string
        |> required "safetyNoteTitle" string
        |> required "safetyNoteBody" string

heatingDecoder : Decoder HeatingStrings
heatingDecoder =
    Decode.succeed HeatingStrings
        |> required "title" string
        |> required "explanation" string
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
        |> required "explanation" string
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
    Decode.succeed RapidChillingStrings
        |> required "title" string
        |> required "explanation" string
        |> required "shape" string
        |> required "thickness" string
        |> required "resultHeader" string
        |> required "resultSuffix" string
        |> required "errorThickness" string

brineDecoder : Decoder BrineStrings
brineDecoder =
    Decode.succeed BrineStrings
        |> required "title" string
        |> required "explanation" string
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
    Decode.succeed DonenessStrings
        |> required "title" string
        |> required "explanation" string
        |> required "protein" string
        |> required "meat" string
        |> required "fish" string
        |> required "beef" donenessBeefDecoder
        |> required "fishDesc" donenessFishDecoder

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
    Decode.succeed ShelfLifeStrings
        |> required "title" string
        |> required "explanation" string
        |> required "temp" string
        |> required "resultHeader" string
        |> required "suffix" string
        |> required "error" string

-- Helper for large records
required : String -> Decoder a -> Decoder (a -> b) -> Decoder b
required key valDecoder decoder =
    map2 (|>) (field key valDecoder) decoder