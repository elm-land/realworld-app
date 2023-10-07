module Pages.Profile.Username_ exposing (Model, Msg, page)

import Api
import Api.Article exposing (Article)
import Api.Article.Filters as Filters
import Api.Data exposing (Data)
import Api.Profile exposing (Profile)
import Api.Token exposing (Token)
import Components.ArticleList
import Components.IconButton as IconButton
import Components.NotFound
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class, classList, src)
import Html.Events as Events
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Utils.Maybe
import View exposing (View)


page : Shared.Model -> Route { username : String } -> Page Model Msg
page shared req =
    Page.new
        { init = init shared req
        , update = update shared
        , subscriptions = subscriptions
        , view = view shared
        }
        |> Page.withLayout (\_ -> Layouts.Default {})



-- INIT


type alias Model =
    { username : String
    , profile : Data Profile
    , listing : Data Api.Article.Listing
    , selectedTab : Tab
    , page : Int
    }


type Tab
    = MyArticles
    | FavoritedArticles


init : Shared.Model -> Route { username : String } -> () -> ( Model, Effect Msg )
init shared { params } _ =
    let
        token : Maybe Token
        token =
            Maybe.map .token shared.user
    in
    ( { username = params.username
      , profile = Api.Data.Loading
      , listing = Api.Data.Loading
      , selectedTab = MyArticles
      , page = 1
      }
    , Effect.batch
        [ Api.Profile.get
            { token = token
            , username = params.username
            , onResponse = GotProfile
            }
            |> Effect.sendCmd
        , fetchArticlesBy token params.username 1
        ]
    )


fetchArticlesBy : Maybe Token -> String -> Int -> Effect Msg
fetchArticlesBy token username page_ =
    Api.Article.list
        { token = token
        , page = page_
        , filters = Filters.create |> Filters.byAuthor username
        , onResponse = GotArticles
        }
        |> Effect.sendCmd


fetchArticlesFavoritedBy : Maybe Token -> String -> Int -> Effect Msg
fetchArticlesFavoritedBy token username page_ =
    Api.Article.list
        { token = token
        , page = page_
        , filters =
            Filters.create |> Filters.favoritedBy username
        , onResponse = GotArticles
        }
        |> Effect.sendCmd



-- UPDATE


type Msg
    = GotProfile (Data Profile)
    | GotArticles (Data Api.Article.Listing)
    | Clicked Tab
    | ClickedFavorite Api.User Article
    | ClickedUnfavorite Api.User Article
    | UpdatedArticle (Data Article)
    | ClickedFollow Api.User Profile
    | ClickedUnfollow Api.User Profile
    | ClickedPage Int


update : Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update shared msg model =
    case msg of
        GotProfile profile ->
            ( { model | profile = profile }
            , Effect.none
            )

        ClickedFollow user profile ->
            ( model
            , Api.Profile.follow
                { token = user.token
                , username = profile.username
                , onResponse = GotProfile
                }
                |> Effect.sendCmd
            )

        ClickedUnfollow user profile ->
            ( model
            , Api.Profile.unfollow
                { token = user.token
                , username = profile.username
                , onResponse = GotProfile
                }
                |> Effect.sendCmd
            )

        GotArticles listing ->
            ( { model | listing = listing }
            , Effect.none
            )

        Clicked MyArticles ->
            ( { model
                | selectedTab = MyArticles
                , listing = Api.Data.Loading
                , page = 1
              }
            , fetchArticlesBy (Maybe.map .token shared.user) model.username 1
            )

        Clicked FavoritedArticles ->
            ( { model
                | selectedTab = FavoritedArticles
                , listing = Api.Data.Loading
                , page = 1
              }
            , fetchArticlesFavoritedBy (Maybe.map .token shared.user) model.username 1
            )

        ClickedFavorite user article ->
            ( model
            , Api.Article.favorite
                { token = user.token
                , slug = article.slug
                , onResponse = UpdatedArticle
                }
                |> Effect.sendCmd
            )

        ClickedUnfavorite user article ->
            ( model
            , Api.Article.unfavorite
                { token = user.token
                , slug = article.slug
                , onResponse = UpdatedArticle
                }
                |> Effect.sendCmd
            )

        ClickedPage page_ ->
            let
                fetch : Maybe Token -> String -> Int -> Effect Msg
                fetch =
                    case model.selectedTab of
                        MyArticles ->
                            fetchArticlesBy

                        FavoritedArticles ->
                            fetchArticlesFavoritedBy
            in
            ( { model
                | listing = Api.Data.Loading
                , page = page_
              }
            , fetch
                (shared.user |> Maybe.map .token)
                model.username
                page_
            )

        UpdatedArticle (Api.Data.Success article) ->
            ( { model
                | listing =
                    Api.Data.map (Api.Article.updateArticle article)
                        model.listing
              }
            , Effect.none
            )

        UpdatedArticle _ ->
            ( model, Effect.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    { title = "Profile"
    , body =
        case model.profile of
            Api.Data.Success profile ->
                [ viewProfile shared profile model ]

            Api.Data.Failure _ ->
                [ Components.NotFound.view ]

            _ ->
                []
    }


viewProfile : Shared.Model -> Profile -> Model -> Html Msg
viewProfile shared profile model =
    let
        isViewingOwnProfile : Bool
        isViewingOwnProfile =
            Maybe.map .username shared.user == Just profile.username

        viewUserInfo : Html Msg
        viewUserInfo =
            div [ class "user-info" ]
                [ div [ class "container" ]
                    [ div [ class "row" ]
                        [ div [ class "col-xs-12 col-md-10 offset-md-1" ]
                            [ img [ class "user-img", src profile.image ] []
                            , h4 [] [ text profile.username ]
                            , Utils.Maybe.view profile.bio
                                (\bio -> p [] [ text bio ])
                            , if isViewingOwnProfile then
                                text ""

                              else
                                Utils.Maybe.view shared.user <|
                                    \user ->
                                        if profile.following then
                                            IconButton.view
                                                { color = IconButton.FilledGray
                                                , icon = IconButton.Plus
                                                , label = "Unfollow " ++ profile.username
                                                , onClick = ClickedUnfollow user profile
                                                }

                                        else
                                            IconButton.view
                                                { color = IconButton.OutlinedGray
                                                , icon = IconButton.Plus
                                                , label = "Follow " ++ profile.username
                                                , onClick = ClickedFollow user profile
                                                }
                            ]
                        ]
                    ]
                ]

        viewTabRow : Html Msg
        viewTabRow =
            div [ class "articles-toggle" ]
                [ ul [ class "nav nav-pills outline-active" ]
                    (List.map viewTab [ MyArticles, FavoritedArticles ])
                ]

        viewTab : Tab -> Html Msg
        viewTab tab =
            li [ class "nav-item" ]
                [ button
                    [ class "nav-link"
                    , Events.onClick (Clicked tab)
                    , classList [ ( "active", tab == model.selectedTab ) ]
                    ]
                    [ text
                        (case tab of
                            MyArticles ->
                                "My Articles"

                            FavoritedArticles ->
                                "Favorited Articles"
                        )
                    ]
                ]
    in
    div [ class "profile-page" ]
        [ viewUserInfo
        , div [ class "container" ]
            [ div [ class "row" ]
                [ div [ class "col-xs-12 col-md-10 offset-md-1" ]
                    (viewTabRow
                        :: Components.ArticleList.view
                            { user = shared.user
                            , articleListing = model.listing
                            , onFavorite = ClickedFavorite
                            , onUnfavorite = ClickedUnfavorite
                            , onPageClick = ClickedPage
                            }
                    )
                ]
            ]
        ]
