module Models exposing (Event, Info, Model, Person, Photo, InfoPerson, Page(..))

-- import Pages.Events as Events

type Page = Members
    | Events

type alias Model =
    { members : List Person
    , events : List Event
    , page : Page
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
