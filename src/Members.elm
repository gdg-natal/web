
import Browser
import Dict
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
    | Success (List Champ)


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, getMyJSON )



-- UPDATE


type Msg
    = RepeatPlease
    | GotJSON (Result Http.Error (List Champ))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RepeatPlease ->
            ( Loading, getMyJSON )

        GotJSON result ->
            case result of
                Ok url ->
                    let
                        succ =
                            Debug.log "data" url
                    in
                    ( Success url, Cmd.none )

                Err erro ->
                    let
                        err =
                            Debug.log "dataErro" erro
                    in
                    ( Failure, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Lista de Membros do GDG - Natal" ]
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
                [ div []
                    [ ul [] (List.map printItem url) ]
                ]


printItem : Champ -> Html Msg
printItem champ =
    li []
        [ h3 [] [ text champ.name ]
        , p [] [ text ("ID: " ++ String.fromInt champ.id) ]
        ]


-- HTTP


getMyJSON : Cmd Msg
getMyJSON =
    Http.get
        { url = "https://gdg-natal-dda19.firebaseio.com/members.json"
        , expect = Http.expectJson GotJSON decoder
        }


type alias Champ =
    { chave : String
    , id : Int
    , name : String
    }


decoder : Decode.Decoder (List Champ)
decoder =
    Decode.map papacudocurioso (Decode.dict infoDecoder)
       
papacudocurioso :  Dict.Dict String Info -> List Champ
papacudocurioso = List.map Tuple.second << Dict.toList << Dict.map infoToChamp

type alias Info =
    { id : Int
    , name : String
    }


infoDecoder : Decode.Decoder Info
infoDecoder =
    Decode.succeed Info
        |> Decode.required "id" Decode.int
        |> Decode.optional "name" Decode.string ""
        -- (Decode.field "name" Decode.string)


infoToChamp : String -> Info -> Champ
infoToChamp chave { id, name } =
    Champ chave id name
