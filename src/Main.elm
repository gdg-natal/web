module Main exposing (main, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Models exposing (Event, Info, Model, Page(..), Person)
import Msgs exposing (Msg(..))
import Pages.Events as Events
import Pages.Members as Members
import Url


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { members = []
      , events = []
      , page = Members
      , url = url
      , key = key
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
                            Debug.log "dataEvents" data
                    in
                    ( { model | events = data }, Cmd.none )

                Err erro ->
                    let
                        err =
                            Debug.log "dataErro" erro
                    in
                    ( model, Cmd.none )

        GotMembersJSON result ->
            case result of
                Ok data ->
                    let
                        succ =
                            Debug.log "dataMembers" data
                    in
                    ( { model | members = data }, Cmd.none )

                Err erro ->
                    let
                        err =
                            Debug.log "dataErro" erro
                    in
                    ( model, Cmd.none )

        ChangePage pageToChange ->
            ( { model | page = pageToChange }, Cmd.none )

        UrlChanged url ->
            ( model
            , Cmd.none
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( { model | url = url }, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )



-- MAIN


main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


view : Model -> Browser.Document Msg
view model =
    let
        page =
            case model.url.path of
                "/events" ->
                    Events.view model

                _ ->
                    Members.view model
    in
    { title = "GDG"
    , body =
        [ div []
            [ viewLink "/members"
            , viewLink "/events"
            , page
            ]
        ]
    }


viewLink : String -> Html Msg
viewLink path =
    li [] [ a [ href path ] [ text path ] ]
