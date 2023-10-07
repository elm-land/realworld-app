module Shared.Model exposing (Model)

import Api


type alias Model =
    { user : Maybe Api.User
    }
