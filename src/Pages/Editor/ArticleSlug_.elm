module Pages.Editor.ArticleSlug_ exposing (Model, Msg, page)

import Api
import Api.Article exposing (Article)
import Api.Data exposing (Data)
import Auth
import Components.Editor exposing (Field, Form)
import Dict exposing (Dict)
import Effect exposing (Effect)
import Html exposing (..)
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


page : Auth.User -> Shared.Model -> Route { articleSlug : String } -> Page Model Msg
page user shared route =
    Page.new
        { init = init shared route
        , update = update route
        , subscriptions = subscriptions
        , view = view user
        }
        |> Page.withLayout (\_ -> Layouts.Default {})



-- INIT


type alias Model =
    { slug : String
    , form : Maybe Form
    , article : Data Article
    }


init : Shared.Model -> Route { articleSlug : String } -> () -> ( Model, Effect Msg )
init shared { params } _ =
    ( { slug = params.articleSlug
      , form = Nothing
      , article = Api.Data.Loading
      }
    , Api.Article.get
        { token = shared.user |> Maybe.map .token
        , slug = params.articleSlug
        , onResponse = LoadedInitialArticle
        }
        |> Effect.sendCmd
    )



-- UPDATE


type Msg
    = SubmittedForm Api.User Form
    | Updated Field String
    | UpdatedArticle (Data Article)
    | LoadedInitialArticle (Data Article)


update : Route { articleSlug : String } -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        LoadedInitialArticle article ->
            case article of
                Api.Data.Success a ->
                    ( { model
                        | form =
                            Just <|
                                { title = a.title
                                , description = a.description
                                , body = a.body
                                , tags = String.join ", " a.tags
                                }
                      }
                    , Effect.none
                    )

                _ ->
                    ( model, Effect.none )

        Updated field value ->
            ( { model
                | form =
                    Maybe.map
                        (Components.Editor.updateField field value)
                        model.form
              }
            , Effect.none
            )

        SubmittedForm user form ->
            ( model
            , Api.Article.update
                { token = user.token
                , slug = model.slug
                , article =
                    { title = form.title
                    , description = form.description
                    , body = form.body
                    , tags =
                        form.tags
                            |> String.split ","
                            |> List.map String.trim
                    }
                , onResponse = UpdatedArticle
                }
                |> Effect.sendCmd
            )

        UpdatedArticle article ->
            ( { model | article = article }
            , case article of
                Api.Data.Success newArticle ->
                    Effect.pushRoute
                        { path = Route.Path.Article_Slug_ { slug = newArticle.slug }
                        , query = Dict.empty
                        , hash = Nothing
                        }

                _ ->
                    Effect.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Api.User -> Model -> View Msg
view user model =
    { title = "Editing Article"
    , body =
        case model.form of
            Just form ->
                [ Components.Editor.view
                    { onFormSubmit = SubmittedForm user form
                    , title = "Edit Article"
                    , form = form
                    , onUpdate = Updated
                    , buttonLabel = "Save"
                    , article = model.article
                    }
                ]

            Nothing ->
                []
    }
