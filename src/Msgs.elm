module Msgs exposing (Msg(..))

import Http exposing (..)
import Models exposing (..)
import Browser
import Url


type Msg
    = LoadEvents
    | LoadMembers
    | GotEventsJSON (Result Http.Error (List (Searchable Event)))
    | GotMembersJSON (Result Http.Error (List (Searchable Person)))
    | ChangePage Page
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | KeyPress String
