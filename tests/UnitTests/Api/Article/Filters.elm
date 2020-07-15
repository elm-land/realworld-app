module UnitTests.Api.Article.Filters exposing (suite)

import Api.Article.Filters as Filters exposing (Filters)
import Expect
import Test exposing (..)


suite : Test
suite =
    describe "Api.Article.Filters"
        [ describe "pageQueryParameters"
            [ test "works with page 1" <|
                \_ ->
                    Filters.pageQueryParameters 1
                        |> Expect.equal "?limit=20&offset=0"
            , test "increases offset by a multiple of 20" <|
                \_ ->
                    [ Filters.pageQueryParameters 2
                    , Filters.pageQueryParameters 3
                    , Filters.pageQueryParameters 4
                    ]
                        |> Expect.equalLists
                            [ "?limit=20&offset=20"
                            , "?limit=20&offset=40"
                            , "?limit=20&offset=60"
                            ]
            ]
        , describe "toQueryString"
            [ test "returns limit and offset by default" <|
                \_ ->
                    Filters.create
                        |> Filters.toQueryString
                        |> Expect.equal "?limit=20&offset=0"
            , test "supports tag filter" <|
                \_ ->
                    Filters.create
                        |> Filters.withTag "dragons"
                        |> Filters.toQueryString
                        |> Expect.equal "?limit=20&offset=0&tag=dragons"
            , test "supports author filter" <|
                \_ ->
                    Filters.create
                        |> Filters.byAuthor "ryan"
                        |> Filters.toQueryString
                        |> Expect.equal "?limit=20&offset=0&author=ryan"
            , test "supports favorited filter" <|
                \_ ->
                    Filters.create
                        |> Filters.favoritedBy "erik"
                        |> Filters.toQueryString
                        |> Expect.equal "?limit=20&offset=0&favorited=erik"
            , test "supports multiple filters" <|
                \_ ->
                    Filters.create
                        |> Filters.byAuthor "ryan"
                        |> Filters.withTag "dragons"
                        |> Filters.favoritedBy "erik"
                        |> Filters.toQueryString
                        |> Expect.equal "?limit=20&offset=0&tag=dragons&author=ryan&favorited=erik"
            ]
        ]
