module Pages.Members exposing (view, getMyJSON)

import Browser
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Models exposing (InfoPerson, Model, Person, Photo)
import Msgs exposing (Msg(..))


-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Lista de Membros do GDG - Natal" ]
        , button [ onClick LoadMembers ] [ text "vem ni mim" ]
        , viewJSON model
        ]


viewJSON : Model -> Html Msg
viewJSON model =
    div []
        [ div []
            [ ul [] (List.map printItem model.members) ]
        ]


printItem : Person -> Html Msg
printItem person =
    li []
        [ h3 [] [ text person.name ]
        , p [] [ text ("ID: " ++ String.fromInt person.id) ]
        ]



-- HTTP


getMyJSON : Cmd Msg
getMyJSON =
    Http.get
        { url = "https://gdg-natal-dda19.firebaseio.com/members.json"
        , expect = Http.expectJson GotMembersJSON decoder
        }


decoder : Decode.Decoder (List Person)
decoder =
    Decode.map papacudocurioso (Decode.dict infoDecoder)


papacudocurioso : Dict.Dict String InfoPerson -> List Person
papacudocurioso =
    List.map Tuple.second << Dict.toList << Dict.map infoToChamp


infoDecoder : Decode.Decoder InfoPerson
infoDecoder =
    Decode.succeed InfoPerson
        |> Decode.required "id" Decode.int
        |> Decode.optional "name" Decode.string ""



-- (Decode.field "name" Decode.string)


infoToChamp : String -> InfoPerson -> Person
infoToChamp chave { id, name } =
    Person chave id name
