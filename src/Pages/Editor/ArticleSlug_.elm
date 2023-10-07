module Pages.Editor.ArticleSlug_ exposing (Model, Msg, page)

import Api
import Api.Data exposing (Data)
import Auth
import Components.Editor exposing (Field, Form)
import Dict
import Effect exposing (Effect)
import Html exposing (..)
import Http
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
    , article : Data Api.Article
    }


init : Shared.Model -> Route { articleSlug : String } -> () -> ( Model, Effect Msg )
init _ { params } _ =
    ( { slug = params.articleSlug
      , form = Nothing
      , article = Api.Data.Loading
      }
    , Api.getArticle
        { params = { slug = params.articleSlug }
        , toMsg = LoadedInitialArticle
        }
        |> Effect.sendCmd
    )



-- UPDATE


type Msg
    = SubmittedForm Api.User Form
    | Updated Field String
    | UpdatedArticle (Result Http.Error Api.SingleArticleResponse)
    | LoadedInitialArticle (Result Http.Error Api.SingleArticleResponse)


update : Route { articleSlug : String } -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        LoadedInitialArticle response ->
            case response of
                Ok { article } ->
                    ( { model
                        | form =
                            Just <|
                                { title = article.title
                                , description = article.description
                                , body = article.body
                                , tags = String.join ", " article.tagList
                                }
                      }
                    , Effect.none
                    )

                Err _ ->
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
            , Api.updateArticle
                { authorization = { token = user.token }
                , params = { slug = model.slug }
                , body =
                    { article =
                        { body = Just form.body
                        , description = Just form.description
                        , title = Just form.title
                        }
                    }
                , toMsg = UpdatedArticle
                }
                |> Effect.sendCmd
            )

        UpdatedArticle response ->
            ( { model
                | article =
                    response
                        |> Result.map .article
                        |> Result.mapError (\_ -> [ "Failed to update article" ])
                        |> Api.Data.fromResult
              }
            , case response of
                Ok { article } ->
                    Effect.pushRoute
                        { path = Route.Path.Article_Slug_ { slug = article.slug }
                        , query = Dict.empty
                        , hash = Nothing
                        }

                Err _ ->
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
