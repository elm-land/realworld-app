module Pages.Register exposing (Model, Msg, page)

import Api
import Api.Data exposing (Data)
import Components.UserForm
import Dict exposing (Dict)
import Effect exposing (Effect)
import Html exposing (..)
import Http
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared req =
    Page.new
        { init = init shared
        , update = update req
        , subscriptions = subscriptions
        , view = view
        }
        |> Page.withLayout (\_ -> Layouts.Default {})



-- INIT


type alias Model =
    { user : Data Api.User
    , username : String
    , email : String
    , password : String
    }


init : Shared.Model -> () -> ( Model, Effect Msg )
init shared _ =
    ( Model
        (case shared.user of
            Just user ->
                Api.Data.Success user

            Nothing ->
                Api.Data.NotAsked
        )
        ""
        ""
        ""
    , Effect.none
    )



-- UPDATE


type Msg
    = Updated Field String
    | AttemptedSignUp
    | GotUser (Result Http.Error Api.UserResponse)


type Field
    = Username
    | Email
    | Password


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update req msg model =
    case msg of
        Updated Username username ->
            ( { model | username = username }
            , Effect.none
            )

        Updated Email email ->
            ( { model | email = email }
            , Effect.none
            )

        Updated Password password ->
            ( { model | password = password }
            , Effect.none
            )

        AttemptedSignUp ->
            ( model
            , Api.createUser
                { body =
                    { user =
                        { username = model.username
                        , email = model.email
                        , password = model.password
                        }
                    }
                , toMsg = GotUser
                }
                |> Effect.sendCmd
            )

        GotUser response ->
            let
                user =
                    response
                        |> Result.mapError (\_ -> [ "Failed to register" ])
                        |> Result.map .user
                        |> Api.Data.fromResult
            in
            case Api.Data.toMaybe user of
                Just user_ ->
                    ( { model | user = user }
                    , Effect.batch
                        [ Effect.pushRoute
                            { path = Route.Path.Home_
                            , query = Dict.empty
                            , hash = Nothing
                            }
                        , Effect.signIn user_
                        ]
                    )

                Nothing ->
                    ( { model | user = user }
                    , Effect.none
                    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Sign up"
    , body =
        [ Components.UserForm.view
            { user = model.user
            , label = "Sign up"
            , onFormSubmit = AttemptedSignUp
            , alternateLink =
                { label = "Have an account?"
                , route = Route.Path.Login
                }
            , fields =
                [ { label = "Your Name"
                  , type_ = "text"
                  , value = model.username
                  , onInput = Updated Username
                  }
                , { label = "Email"
                  , type_ = "email"
                  , value = model.email
                  , onInput = Updated Email
                  }
                , { label = "Password"
                  , type_ = "password"
                  , value = model.password
                  , onInput = Updated Password
                  }
                ]
            }
        ]
    }
