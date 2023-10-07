module Pages.Home_ exposing (Model, Msg, page)

import Api
import Api.Article exposing (Article)
import Api.Article.Filters as Filters
import Api.Article.Tag exposing (Tag)
import Api.Data exposing (Data)
import Components.ArticleList
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.Events as Events
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Utils.Maybe
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared _ =
    Page.new
        { init = init shared
        , update = update shared
        , subscriptions = subscriptions
        , view = view shared
        }
        |> Page.withLayout (\_ -> Layouts.Default {})



-- INIT


type alias Model =
    { listing : Data Api.Article.Listing
    , page : Int
    , tags : Data (List Tag)
    , activeTab : Tab
    }


type Tab
    = FeedFor Api.User
    | Global
    | TagFilter Tag


init : Shared.Model -> () -> ( Model, Effect Msg )
init shared _ =
    let
        activeTab : Tab
        activeTab =
            shared.user
                |> Maybe.map FeedFor
                |> Maybe.withDefault Global

        model : Model
        model =
            { listing = Api.Data.Loading
            , page = 1
            , tags = Api.Data.Loading
            , activeTab = activeTab
            }
    in
    ( model
    , Effect.batch
        [ fetchArticlesForTab shared model
        , Api.Article.Tag.list { onResponse = GotTags }
            |> Effect.sendCmd
        ]
    )


fetchArticlesForTab :
    Shared.Model
    ->
        { model
            | page : Int
            , activeTab : Tab
        }
    -> Effect Msg
fetchArticlesForTab shared model =
    case model.activeTab of
        Global ->
            Api.Article.list
                { filters = Filters.create
                , page = model.page
                , token = Maybe.map .token shared.user
                , onResponse = GotArticles
                }
                |> Effect.sendCmd

        FeedFor user ->
            Api.Article.feed
                { token = user.token
                , page = model.page
                , onResponse = GotArticles
                }
                |> Effect.sendCmd

        TagFilter tag ->
            Api.Article.list
                { filters =
                    Filters.create
                        |> Filters.withTag tag
                , page = model.page
                , token = Maybe.map .token shared.user
                , onResponse = GotArticles
                }
                |> Effect.sendCmd



-- UPDATE


type Msg
    = GotArticles (Data Api.Article.Listing)
    | GotTags (Data (List Tag))
    | SelectedTab Tab
    | ClickedFavorite Api.User Article
    | ClickedUnfavorite Api.User Article
    | ClickedPage Int
    | UpdatedArticle (Data Article)


update : Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update shared msg model =
    case msg of
        GotArticles listing ->
            ( { model | listing = listing }
            , Effect.none
            )

        GotTags tags ->
            ( { model | tags = tags }
            , Effect.none
            )

        SelectedTab tab ->
            let
                newModel : Model
                newModel =
                    { model
                        | activeTab = tab
                        , listing = Api.Data.Loading
                        , page = 1
                    }
            in
            ( newModel
            , fetchArticlesForTab shared newModel
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
                newModel : Model
                newModel =
                    { model
                        | listing = Api.Data.Loading
                        , page = page_
                    }
            in
            ( newModel
            , fetchArticlesForTab shared newModel
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
    { title = ""
    , body =
        [ div [ class "home-page" ]
            [ div [ class "banner" ]
                [ div [ class "container" ]
                    [ h1 [ class "logo-font" ] [ text "conduit" ]
                    , p [] [ text "A place to share your knowledge." ]
                    ]
                ]
            , div [ class "container page" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-9" ] <|
                        (viewTabs shared model
                            :: Components.ArticleList.view
                                { user = shared.user
                                , articleListing = model.listing
                                , onFavorite = ClickedFavorite
                                , onUnfavorite = ClickedUnfavorite
                                , onPageClick = ClickedPage
                                }
                        )
                    , div [ class "col-md-3" ] [ viewTags model.tags ]
                    ]
                ]
            ]
        ]
    }


viewTabs :
    Shared.Model
    -> { model | activeTab : Tab }
    -> Html Msg
viewTabs shared model =
    div [ class "feed-toggle" ]
        [ ul [ class "nav nav-pills outline-active" ]
            [ Utils.Maybe.view shared.user <|
                \user ->
                    li [ class "nav-item" ]
                        [ button
                            [ class "nav-link"
                            , classList [ ( "active", model.activeTab == FeedFor user ) ]
                            , Events.onClick (SelectedTab (FeedFor user))
                            ]
                            [ text "Your Feed" ]
                        ]
            , li [ class "nav-item" ]
                [ button
                    [ class "nav-link"
                    , classList [ ( "active", model.activeTab == Global ) ]
                    , Events.onClick (SelectedTab Global)
                    ]
                    [ text "Global Feed" ]
                ]
            , case model.activeTab of
                TagFilter tag ->
                    li [ class "nav-item" ] [ a [ class "nav-link active" ] [ text ("#" ++ tag) ] ]

                _ ->
                    text ""
            ]
        ]


viewTags : Data (List Tag) -> Html Msg
viewTags data =
    case data of
        Api.Data.Success tags ->
            div [ class "sidebar" ]
                [ p [] [ text "Popular Tags" ]
                , div [ class "tag-list" ] <|
                    List.map
                        (\tag ->
                            button
                                [ class "tag-pill tag-default"
                                , Events.onClick (SelectedTab (TagFilter tag))
                                ]
                                [ text tag ]
                        )
                        tags
                ]

        _ ->
            text ""
