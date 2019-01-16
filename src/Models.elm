module Models exposing (Event, JsonEvent, InfoPerson, Model, Page(..), Person, Photo, Searchable)

import Browser.Navigation as Nav
import Url


type Page
    = Members
    | Events


type alias Model =
    { members : List (Searchable Person)
    , events : List (Searchable Event)
    , eventsFiltered : List (Searchable Event)
    , membersFiltered : List (Searchable Person)
    , page : Page
    , key : Nav.Key
    , url : Url.Url
    , find : String
    }

-- Models Members


type alias Photo =
    { photo_link : String }

type alias Searchable a = 
    { searchKey : String
    , obj : a
    }

type alias Person =
    { chave : String
    , id : Int
    , name : String
    , photo : Photo
    }


type alias InfoPerson =
    { id : Int
    , name : String
    , photo : Photo
    }



-- Models Events


type alias Event =
    { chave : String
    , description : String
    , name : String
    }


type alias JsonEvent =
    { description : String
    , name : String
    }
