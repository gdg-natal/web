module Main exposing (main, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Models exposing (..)
import Msgs exposing (Msg(..))
import Pages.Events as Events
import Pages.Members as Members
import Url


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        msg =
            case url.path of
                "/events" ->
                    Events.getMyJSON

                _ ->
                    Members.getMyJSON
    in
    ( { members = []
      , events = []
      , eventsFiltered = []
      , membersFiltered = []
      , page = Members
      , url = url
      , key = key
      , find = ""
      }
    , msg
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
                    ( { model | events = data, eventsFiltered = data }, Cmd.none )

                Err erro ->
                    let
                        err =
                            Debug.log "dataErro" erro
                    in
                    ( model, Cmd.none )

        GotMembersJSON result ->
            case result of
                Ok data ->
                    ( { model | members = data, membersFiltered = data }, Cmd.none )
                    
                Err erro ->
                    let
                        err =
                            Debug.log "dataErro" erro
                    in
                    ( model, Cmd.none )

        ChangePage pageToChange ->
            let
                cmd =
                    case model.url.path of
                        "/events" ->
                            Events.getMyJSON

                        _ ->
                            Members.getMyJSON
            in
            ( { model | page = pageToChange }, cmd )

        UrlChanged url ->
            let
                cmd =
                    case url.path of
                        "/events" ->
                            Events.getMyJSON

                        _ ->
                            Members.getMyJSON
            in
            ( model
            , cmd
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( { model | url = url }, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        KeyPress newContent ->
            let
                membersFiltered = 
                    case newContent of
                        "" ->  
                            model.members
                    
                        _ ->
                            Members.filterMembers newContent model.members

                eventsFiltered = 
                    case newContent of
                        "" ->  
                            model.events
                    
                        _ ->
                            Events.filterEvents newContent model.events
            in
            ( { model |find = newContent, membersFiltered = membersFiltered, eventsFiltered = eventsFiltered }, Cmd.none )


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
