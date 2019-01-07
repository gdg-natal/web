module Msgs exposing (Msg(..))

import Http exposing (..)
import Models exposing (Event, Person, Page)


type Msg
    = LoadEvents
    | LoadMembers
    | GotEventsJSON (Result Http.Error (List Event))
    | GotMembersJSON (Result Http.Error (List Person))
    | ChangePage Page