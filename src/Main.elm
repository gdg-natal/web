module Main exposing (main, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Models exposing (Event, Info, Model, Person, Photo, Page(..))
import Msgs exposing (Msg(..))
import Pages.Events as Events
import Pages.Members as Members


init : () -> ( Model, Cmd Msg )
init _ =
    ( { members = []
      , events = []
      , page = Members
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadEvents ->
            ( model
            , Events.getMyJSON
            )

        LoadMembers ->
            ( model
            , Members.getMyJSON
            )

        GotEventsJSON result ->
            case result of
                Ok data ->
                    let
                        succ =
                            Debug.log "data" data
                    in
                    ( { model | events = data }, Cmd.none )

                Err erro ->
                    let
                        err =
                            Debug.log "dataErro" erro
                    in
                    ( model, Cmd.none )

        GotMembersJSON _ ->
            ( model
            , Cmd.none
            )

        ChangePage pageToChange ->
            ({ model | page = pageToChange } , Cmd.none)


-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


view : Model -> Html Msg
view model =
    let
        currentPage =
            case model.page of
                Events ->
                    Events.view model
                Members ->
                    Members.view model
    in
    div []
        [ button [ onClick (ChangePage Events) ] [ text "Events" ]
        , button [ onClick (ChangePage Members) ] [ text "Members" ]
        , currentPage
        ]
