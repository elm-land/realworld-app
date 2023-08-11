module Shared.Model exposing (Model)

import Api.User exposing (User)


type alias Model =
    { user : Maybe User
    }
