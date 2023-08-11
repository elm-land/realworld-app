module Auth exposing (User, onPageLoad, viewLoadingPage)

import Api.User
import Dict exposing (Dict)
import ElmSpa.Page as ElmSpa
import Route exposing (Route)
import Shared
import View exposing (View)


type alias User =
    Api.User.User


onPageLoad : Shared.Model -> Route () -> Auth.Action.Action User
onPageLoad shared req =
    case shared.user of
        Just user ->
            Auth.Action.loadPageWithUser user

        Nothing ->
            Auth.Action.replaceRoute
                { path = Route.Path.Login
                , query = Dict.empty
                , hash = Nothing
                }


viewLoadingPage : Shared.Model -> Route () -> View Never
viewLoadingPage shared route =
    View.none
