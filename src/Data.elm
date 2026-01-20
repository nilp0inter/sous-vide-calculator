module Data exposing (..)

import Json.Decode as Decode exposing (Decoder, int, float, string, list, nullable, field, map2, map3, map4, map5)

type alias Data =
    { heating : HeatingData
    , pasteurization : PasteurizationData
    , rapidChilling : List ChillingRow
    , doneness : DonenessData
    , shelfLife : List ShelfLifeRule
    , brine : BrineData
    }

type alias HeatingData =
    { thawed : List HeatingRow
    , frozen : List HeatingRow
    }

type alias HeatingRow =
    { thickness : Int
    , slab : Maybe Int
    , cylinder : Maybe Int
    , sphere : Maybe Int
    }

type alias PasteurizationData =
    { leanFish : List PasteurizationRow
    , fattyFish : List PasteurizationRow
    , poultry : List PasteurizationRow
    , meat : List PasteurizationRow
    }

type alias PasteurizationRow =
    { thickness : Float
    , times : List (Float, Float)
    }

type alias ChillingRow = HeatingRow

type alias DonenessData =
    { beef : List DonenessLevel
    , fish : List DonenessLevel
    }

type alias DonenessLevel =
    { name : String
    , tempC : Float
    , tempF : Int
    , desc : String
    , color : String
    }

type alias ShelfLifeRule =
    { maxTemp : Float
    , days : Int
    }

type alias BrineData =
    { porkPoultry : BrineRatios
    , brisket : BrineRatios
    }

type alias BrineRatios =
    { saltMin : Float
    , saltMax : Float
    , sugar : Float
    }

-- DECODERS

dataDecoder : Decoder Data
dataDecoder =
    Decode.map6 Data
        (field "heating" heatingDecoder)
        (field "pasteurization" pasteurizationDecoder)
        (field "rapidChilling" (list chillingRowDecoder))
        (field "doneness" donenessDecoder)
        (field "shelfLife" (list shelfLifeRuleDecoder))
        (field "brine" brineDecoder)

heatingDecoder : Decoder HeatingData
heatingDecoder =
    map2 HeatingData
        (field "thawed" (list heatingRowDecoder))
        (field "frozen" (list heatingRowDecoder))

heatingRowDecoder : Decoder HeatingRow
heatingRowDecoder =
    map4 HeatingRow
        (field "thickness" int)
        (field "slab" (nullable int))
        (field "cylinder" (nullable int))
        (field "sphere" (nullable int))

chillingRowDecoder : Decoder ChillingRow
chillingRowDecoder = heatingRowDecoder

pasteurizationDecoder : Decoder PasteurizationData
pasteurizationDecoder =
    map4 PasteurizationData
        (field "leanFish" (list pasteurizationRowDecoder))
        (field "fattyFish" (list pasteurizationRowDecoder))
        (field "poultry" (list pasteurizationRowDecoder))
        (field "meat" (list pasteurizationRowDecoder))

pasteurizationRowDecoder : Decoder PasteurizationRow
pasteurizationRowDecoder =
    map2 PasteurizationRow
        (field "thickness" float)
        (field "times" (list (Decode.map2 Tuple.pair (Decode.index 0 float) (Decode.index 1 float))))

donenessDecoder : Decoder DonenessData
donenessDecoder =
    map2 DonenessData
        (field "beef" (list donenessLevelDecoder))
        (field "fish" (list donenessLevelDecoder))

donenessLevelDecoder : Decoder DonenessLevel
donenessLevelDecoder =
    map5 DonenessLevel
        (field "name" string)
        (field "tempC" float)
        (field "tempF" int)
        (field "desc" string)
        (field "color" string)

shelfLifeRuleDecoder : Decoder ShelfLifeRule
shelfLifeRuleDecoder =
    map2 ShelfLifeRule
        (field "maxTemp" float)
        (field "days" int)

brineDecoder : Decoder BrineData
brineDecoder =
    map2 BrineData
        (field "porkPoultry" brineRatiosDecoder)
        (field "brisket" brineRatiosDecoder)

brineRatiosDecoder : Decoder BrineRatios
brineRatiosDecoder =
    map3 BrineRatios
        (field "saltMin" float)
        (field "saltMax" float)
        (field "sugar" float)
