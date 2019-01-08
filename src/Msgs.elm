module Msgs exposing (Msg(..))

import Http exposing (..)
import Models exposing (Event, Page, Person)
import Browser
import Url


type Msg
    = LoadEvents
    | LoadMembers
    | GotEventsJSON (Result Http.Error (List Event))
    | GotMembersJSON (Result Http.Error (List Person))
    | ChangePage Page
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
