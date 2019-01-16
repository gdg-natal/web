module Pages.Members exposing (getMyJSON, view, filterMembers)

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
import Models exposing (..)
import Msgs exposing (Msg(..))



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Lista de Membros do GDG - Natal" ]
        , input [ placeholder "Buscar", value model.find, onInput KeyPress ] []
        , br [] []
        , viewJSON model
        ]


viewJSON : Model -> Html Msg
viewJSON model =
    div []
        [ div []
            [ ul [] (List.map printItem model.membersFiltered) ]
        ]

printItem : (Searchable Person) -> Html Msg
printItem person =
    let
        nodes =
            case Html.Parser.run person.obj.name of
                Ok parsedNodes ->
                    Html.Parser.Util.toVirtualDom parsedNodes

                _ ->
                    []  
    in
    li []
        [ h3 [] [ text person.obj.name ]
        , img [ src person.obj.photo.photo_link, height 100 ] []
        , p [] [ text ("ID: " ++ String.fromInt person.obj.id) ]
        ]


filterMembers : String -> List (Searchable a) -> List (Searchable a)
filterMembers str list =
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
        { url = "https://gdg-natal-dda19.firebaseio.com/members.json"
        , expect = Http.expectJson GotMembersJSON decoder
        }


decoder : Decode.Decoder (List (Searchable Person))
decoder =
    Decode.map poMagico (Decode.dict infoDecoder)


poMagico : Dict.Dict String InfoPerson -> List (Searchable Person)
poMagico dict = 
    dict
        |> Dict.map inforPersonToSearchableMember
        |> Dict.toList
        |> List.map Tuple.second

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


inforPersonToSearchableMember : String -> InfoPerson -> Searchable Person
inforPersonToSearchableMember chave { id, name, photo } =
    (Searchable name (Person chave id name photo))