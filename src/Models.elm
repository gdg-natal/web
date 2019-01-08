module Models exposing (Event, Info, InfoPerson, Model, Page(..), Person, Photo)

import Browser.Navigation as Nav
import Url


type Page
    = Members
    | Events


type alias Model =
    { members : List Person
    , events : List Event
    , page : Page
    , key : Nav.Key
    , url : Url.Url
    }



-- Models Members


type alias Photo =
    { base_url : String }


type alias Person =
    { chave : String
    , id : Int
    , name : String
    }


type alias InfoPerson =
    { id : Int
    , name : String
    }



-- Models Events


type alias Event =
    { chave : String
    , description : String
    , name : String
    }


type alias Info =
    { description : String
    , name : String
    }
