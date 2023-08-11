module Shared exposing
    ( Flags
    , Model
    , Msg
    , decoder
    , init
    , subscriptions
    , update
    )

import Api.User exposing (User)
import Components.Footer
import Components.Navbar
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class)
import Json.Decode
import Route exposing (Route)
import Shared.Model
import Shared.Msg
import View exposing (View)



-- INIT


type alias Flags =
    { user : Maybe User
    }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map Flags
        (Json.Decode.maybe (Json.Decode.field "user" Api.User.decoder))


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init result _ =
    let
        flags =
            result
                |> Result.withDefault
                    { user = Nothing
                    }
    in
    ( { user = flags.user
      }
    , Effect.none
    )



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        Shared.Msg.SignedInUser user ->
            ( { model | user = Just user }
            , Effect.saveUser user
            )

        Shared.Msg.ClickedSignOut ->
            ( { model | user = Nothing }
            , Effect.clearUser
            )


subscriptions : Route () -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none



-- VIEW
