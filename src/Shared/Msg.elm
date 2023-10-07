module Shared.Msg exposing (Msg(..))

import Api


type Msg
    = ClickedSignOut
    | SignedInUser Api.User
