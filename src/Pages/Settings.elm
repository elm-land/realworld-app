module Pages.Settings exposing (Model, Msg, page)

import Api
import Api.Data
import Auth
import Components.ErrorList
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, placeholder, type_, value)
import Html.Events as Events
import Http
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Utils.Maybe
import View exposing (View)


page : Auth.User -> Shared.Model -> Route () -> Page Model Msg
page user shared _ =
    Page.new
        { init = init shared
        , update = update
        , subscriptions = subscriptions
        , view = view user
        }
        |> Page.withLayout (\_ -> Layouts.Default {})



-- INIT


type alias Model =
    { image : String
    , username : String
    , bio : String
    , email : String
    , password : Maybe String
    , message : Maybe String
    , errors : List String
    }


init : Shared.Model -> () -> ( Model, Effect Msg )
init shared _ =
    ( case shared.user of
        Just user ->
            { image = user.image
            , username = user.username
            , bio = user.bio |> Maybe.withDefault ""
            , email = user.email
            , password = Nothing
            , message = Nothing
            , errors = []
            }

        Nothing ->
            { image = ""
            , username = ""
            , bio = ""
            , email = ""
            , password = Nothing
            , message = Nothing
            , errors = []
            }
    , Effect.none
    )



-- UPDATE


type Msg
    = Updated Field String
    | SubmittedForm Api.User
    | GotUser (Result Http.Error Api.UserResponse)


type Field
    = Image
    | Username
    | Bio
    | Email
    | Password


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        Updated Image value ->
            ( { model | image = value }, Effect.none )

        Updated Username value ->
            ( { model | username = value }, Effect.none )

        Updated Bio value ->
            ( { model | bio = value }, Effect.none )

        Updated Email value ->
            ( { model | email = value }, Effect.none )

        Updated Password value ->
            ( { model | password = Just value }, Effect.none )

        SubmittedForm user ->
            ( { model | message = Nothing, errors = [] }
            , Effect.sendCmd <|
                Api.updateCurrentUser
                    { authorization = { token = user.token }
                    , body =
                        { user =
                            { bio = Just model.bio
                            , email = Just model.email
                            , image = Just model.image
                            , password = model.password
                            , username = Just model.username
                            }
                        }
                    , toMsg = GotUser
                    }
            )

        GotUser response ->
            let
                userResponse =
                    response
                        |> Result.mapError (\_ -> [ "Faied to update user" ])
                        |> Result.map .user
                        |> Api.Data.fromResult
            in
            case userResponse of
                Api.Data.Success user ->
                    ( { model | message = Just "User updated!" }
                    , Effect.batch
                        [ Effect.saveUser user
                        , Effect.signIn user
                        ]
                    )

                Api.Data.Failure reasons ->
                    ( { model | errors = reasons }
                    , Effect.none
                    )

                _ ->
                    ( model, Effect.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Api.User -> Model -> View Msg
view user model =
    { title = "Settings"
    , body =
        [ div [ class "settings-page" ]
            [ div [ class "container page" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-6 offset-md-3 col-xs-12" ]
                        [ h1 [ class "text-xs-center" ] [ text "Your Settings" ]
                        , br [] []
                        , Components.ErrorList.view model.errors
                        , Utils.Maybe.view model.message <|
                            \message ->
                                p [ class "text-success" ] [ text message ]
                        , form [ Events.onSubmit (SubmittedForm user) ]
                            [ fieldset []
                                [ fieldset [ class "form-group" ]
                                    [ input
                                        [ class "form-control"
                                        , placeholder "URL of profile picture"
                                        , type_ "text"
                                        , value model.image
                                        , Events.onInput (Updated Image)
                                        ]
                                        []
                                    ]
                                , fieldset [ class "form-group" ]
                                    [ input
                                        [ class "form-control form-control-lg"
                                        , placeholder "Your Username"
                                        , type_ "text"
                                        , value model.username
                                        , Events.onInput (Updated Username)
                                        ]
                                        []
                                    ]
                                , fieldset [ class "form-group" ]
                                    [ textarea
                                        [ class "form-control form-control-lg"
                                        , placeholder "Short bio about you"
                                        , attribute "rows" "8"
                                        , value model.bio
                                        , Events.onInput (Updated Bio)
                                        ]
                                        []
                                    ]
                                , fieldset [ class "form-group" ]
                                    [ input
                                        [ class "form-control form-control-lg"
                                        , placeholder "Email"
                                        , type_ "text"
                                        , value model.email
                                        , Events.onInput (Updated Email)
                                        ]
                                        []
                                    ]
                                , fieldset [ class "form-group" ]
                                    [ input
                                        [ class "form-control form-control-lg"
                                        , placeholder "Password"
                                        , type_ "password"
                                        , value (Maybe.withDefault "" model.password)
                                        , Events.onInput (Updated Password)
                                        ]
                                        []
                                    ]
                                , button [ class "btn btn-lg btn-primary pull-xs-right" ] [ text "Update Settings" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    }
