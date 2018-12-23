
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
    | Success (List Evento)


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, getMyJSON )



-- UPDATE


type Msg
    = RepeatPlease
    | GotJSON (Result Http.Error (List Evento))


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
        [ h2 [] [ text "Lista de Eventos do GDG - Natal" ]
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

-- replace : String -> String -> String -> String
printItem : Evento -> Html Msg
printItem evento =
    li []
        [ h3 [] [ text evento.name ]
        , p [] [ text (evento.description = replace All (regex "[abc]") (\_ -> "") )]
        -- , p [] [ text (String.split "<p>" evento.description |> String.join "")  ]
        -- , p [] [ text evento.description ]
        -- , p [] [ text ("ID: " ++ String.fromInt evento.id) ]
        ]


-- HTTP


getMyJSON : Cmd Msg
getMyJSON =
    Http.get
        { url = "https://gdg-natal-dda19.firebaseio.com/events.json"
        , expect = Http.expectJson GotJSON decoder
        }


type alias Evento =
    { chave : String
    , description : String
    , name : String
    }


decoder : Decode.Decoder (List Evento)
decoder =
    Decode.map papacudocurioso (Decode.dict infoDecoder)
       
papacudocurioso :  Dict.Dict String Info -> List Evento
papacudocurioso = List.map Tuple.second << Dict.toList << Dict.map infoToEvento

type alias Info =
    { description : String
    , name : String
    }


infoDecoder : Decode.Decoder Info
infoDecoder =
    Decode.succeed Info
        |> Decode.optional "description" Decode.string ""
        |> Decode.optional "name" Decode.string ""


infoToEvento : String -> Info -> Evento
infoToEvento chave { description, name } =
    Evento chave description name
