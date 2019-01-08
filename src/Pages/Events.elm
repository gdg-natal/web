module Pages.Events exposing (getMyJSON, view)

import Browser
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Parser exposing (..)
import Html.Parser.Util exposing (..)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Models exposing (Event, Info, Model)
import Msgs exposing (Msg(..))



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Lista de Eventos do GDG - Natal" ]
        , button [ onClick LoadEvents ] [ text "Expandir" ]
        , viewJSON model
        ]


viewJSON : Model -> Html Msg
viewJSON model =
    div []
        [ div []
            [ ul [] (List.map printItem model.events) ]
        ]


printItem : Event -> Html Msg
printItem evento =
    let
        nodes =
            case Html.Parser.run evento.description of
                Ok parsedNodes ->
                    Html.Parser.Util.toVirtualDom parsedNodes

                _ ->
                    []
    in
    li []
        [ h3 [] [ text evento.name ]
        , div [] nodes
        ]



-- HTTP


getMyJSON : Cmd Msg
getMyJSON =
    Http.get
        { url = "https://gdg-natal-dda19.firebaseio.com/events.json"
        , expect = Http.expectJson GotEventsJSON decoder
        }


decoder : Decode.Decoder (List Event)
decoder =
    Decode.map papacudocurioso (Decode.dict infoDecoder)


papacudocurioso : Dict.Dict String Info -> List Event
papacudocurioso =
    List.map Tuple.second << Dict.toList << Dict.map infoToEvento


infoDecoder : Decode.Decoder Info
infoDecoder =
    Decode.succeed Info
        |> Decode.optional "description" Decode.string ""
        |> Decode.optional "name" Decode.string ""


infoToEvento : String -> Info -> Event
infoToEvento chave { description, name } =
    Event chave description name
