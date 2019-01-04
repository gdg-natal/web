module Msgs exposing (Msg(..))

import Http exposing (..)
import Models exposing (Event, Person)


type Msg
    = LoadEvents
    | LoadMembers
    | GotEventsJSON (Result Http.Error (List Event))
    | GotMembersJSON (Result Http.Error (List Person))
