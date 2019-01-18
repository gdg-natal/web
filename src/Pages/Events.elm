module Pages.Events exposing (getMyJSON, view, filterEvents)

import Browser
import Dict
import Array
import ElmTextSearch
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Parser exposing (..)
import Html.Parser.Util exposing (..)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Models exposing (..)
import Msgs exposing (Msg(..))



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Lista de Eventos do GDG - Natal" ]
        , input [ placeholder "Buscar", value model.find, onInput KeyPress ] []
        , br [] []
        , viewJSON model
        ]


viewJSON : Model -> Html Msg
viewJSON model =
    div []
        [ div []
            [ ul [] (List.map printItem (Array.toList(Array.slice 0 3 (Array.fromList model.eventsFiltered)))) 
            , pagination 3 model.eventsFiltered
            ]
        ]


printItem : (Searchable Event) -> Html Msg
printItem evento =
    let
        nodes =
            case Html.Parser.run evento.obj.description of
                Ok parsedNodes ->
                    Html.Parser.Util.toVirtualDom parsedNodes

                _ ->
                    []
    in
    li []
        [ h3 [] [ text evento.obj.name ]
        , div [] nodes
        ]


pagination : Float -> List (Searchable a) -> Html Msg
pagination lengthForPage list =
    let
        lng =
            ceiling (toFloat (List.length list) / lengthForPage)
    in
    numbersPage (List.range 1 lng)

    
numbersPage : List Int -> Html Msg
numbersPage list = 
    div [] (List.map (\num -> a [ href "#", style "margin" "0 10px" ] [ text (String.fromInt num) ]) list)


filterEvents : String -> List (Searchable a) -> List (Searchable a)
filterEvents str list =
    List.filter (checkName str) list


checkName : String -> Searchable a -> Bool
checkName str searchable =
    let
        indexes =
            String.indexes (String.toLower str) (String.toLower searchable.searchKey)
    in
    List.length indexes > 0


-- HTTP


getMyJSON : Cmd Msg
getMyJSON =
    Http.get
        { url = "https://gdg-natal-dda19.firebaseio.com/events.json"
        , expect = Http.expectJson GotEventsJSON decoder
        }


decoder : Decode.Decoder (List (Searchable Event))
decoder =
    Decode.map dictToList (Decode.dict jsonEventDecoder)


dictToList : Dict.Dict String JsonEvent -> List (Searchable Event)
dictToList dict = 
    dict
    |> Dict.map jsonEventToSearchableEvent
    |> Dict.toList
    |> List.map Tuple.second


jsonEventDecoder : Decode.Decoder JsonEvent
jsonEventDecoder =
    Decode.succeed JsonEvent
        |> Decode.optional "description" Decode.string ""
        |> Decode.optional "name" Decode.string ""


jsonEventToSearchableEvent : String -> JsonEvent -> Searchable Event
jsonEventToSearchableEvent chave { description, name } =
    (Searchable name (Event chave description name))
