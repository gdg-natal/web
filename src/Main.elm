module Main exposing (Model(..), Msg(..), getMyJSON, init, jsonDecoder, main, subscriptions, update, view, viewJSON)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type Model
    = Failure
    | Loading
    | Success (List Person)


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, getMyJSON )



-- UPDATE


type Msg
    = RepeatPlease
    | GotJSON (Result Http.Error (List Person))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RepeatPlease ->
            ( Loading, getMyJSON )

        GotJSON result ->
            case result of
                Ok url ->
                    ( Success url, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "GET JSON" ]
        , viewJSON model
        ]


viewJSON : Model -> Html Msg
viewJSON model =
    case model of
        Failure ->
            div []
                [ text "I could not load JSON. "
                , button [ onClick RepeatPlease ] [ text "Try Again!" ]
                ]

        Loading ->
            text "Loading..."

        Success url ->
            div []
                [ button [ onClick RepeatPlease, style "display" "block" ] [ text "More Please!" ]
                , div []
                      [ br [] []
                      , text "Text of JSON: "
                      , ul [] (List.map printItem url)
                      ]
                ]


printItem : Person -> Html Msg
printItem person =
   li [] [ text person.name ]



-- HTTP


getMyJSON : Cmd Msg
getMyJSON =
    Http.get
        { expect = Http.expectJson GotJSON jsonDecoder
        , url = "https://gdg-natal-dda19.firebaseio.com/events.json"
        }


type alias Photo =
    { base_url : String }


photoDecoder : Decode.Decoder Photo
photoDecoder =
    Decode.succeed Photo
        |> Decode.required "base_url" Decode.string


type alias Person =
    { id : Int
    , city : String
    , name : String
    , photo : Photo
    }


personDecoder : Decode.Decoder Person
personDecoder =
    Decode.succeed Person
        |> Decode.required "id" Decode.int
        |> Decode.required "city" Decode.string
        |> Decode.required "name" Decode.string
        |> Decode.optional "photo" photoDecoder { base_url = "ai.png" }



jsonDecoder : Decode.Decoder (List Person)
jsonDecoder =
   Decode.list personDecoder
