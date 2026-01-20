module Introduction exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Translations exposing (IntroductionStrings)
import ViewUtils


view : IntroductionStrings -> Html msg
view t =
    div [ class "max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-sm" ]
        [ h2 [ class "text-3xl font-bold mb-8 text-gray-800 border-b pb-4" ]
            [ text t.title ]
        , div [ class "space-y-8" ]
            [ section [ class "space-y-3" ]
                [ h3 [ class "text-xl font-semibold text-indigo-700" ]
                    [ text t.whatIsTitle ]
                , p [ class "text-gray-700 leading-relaxed" ]
                    [ text t.whatIsBody ]
                ]
            , section [ class "bg-gray-50 p-6 rounded-lg border border-gray-100" ]
                [ h3 [ class "text-xl font-semibold text-gray-800 mb-4" ]
                    [ text t.threeStagesTitle ]
                , div [ class "space-y-6" ]
                    [ stageItem t.stage1Title t.stage1Body
                    , stageItem t.stage2Title t.stage2Body
                    , stageItem t.stage3Title t.stage3Body
                    , stageItem t.stage4Title t.stage4Body
                    ]
                ]
            , section [ class "bg-blue-50 p-5 rounded-lg border-l-4 border-blue-500" ]
                [ h3 [ class "text-lg font-bold text-blue-900 mb-2" ]
                    [ text t.safetyNoteTitle ]
                , p [ class "text-blue-800 text-sm leading-relaxed" ]
                    (ViewUtils.parseBody t.safetyNoteBody)
                ]
            ]
        ]


stageItem : String -> String -> Html msg
stageItem title body =
    div []
        [ h4 [ class "text-lg font-medium text-gray-900 mb-1" ]
            [ text title ]
        , p [ class "text-gray-600 leading-relaxed" ]
            (ViewUtils.parseBody body)
        ]
