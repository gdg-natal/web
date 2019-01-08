module Pages.Members exposing (getMyJSON, view)

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
        , button [ onClick LoadMembers ] [ text "Expandir" ]
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
        , img [ src person.photo.photo_link, height 100 ] []
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
    Decode.map poMagico (Decode.dict infoDecoder)


poMagico : Dict.Dict String InfoPerson -> List Person
poMagico =
    List.map Tuple.second << Dict.toList << Dict.map infoToPerson


infoToPerson : String -> InfoPerson -> Person
infoToPerson chave { id, name, photo } =
    Person chave id name photo


photoDecoder : Decode.Decoder Photo
photoDecoder =
    Decode.succeed Photo
        |> Decode.required "photo_link" Decode.string


infoDecoder : Decode.Decoder InfoPerson
infoDecoder =
    Decode.succeed InfoPerson
        |> Decode.required "id" Decode.int
        |> Decode.optional "name" Decode.string "Desconhecido"
        |> Decode.optional "photo" photoDecoder { photo_link = "https://workshopexposicaonainternet.nic.br/seminario-privacidade/img/default-user.png" }
