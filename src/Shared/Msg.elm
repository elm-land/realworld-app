module Shared.Msg exposing (Msg(..))

import Api.User exposing (User)


type Msg
    = ClickedSignOut
    | SignedInUser User
