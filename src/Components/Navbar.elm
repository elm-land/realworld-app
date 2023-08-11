module Components.Navbar exposing (view)

import Api.User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (class, classList, href)
import Html.Events as Events
import Route.Path exposing (Path)


view :
    { user : Maybe User
    , currentRoutePath : Path
    , onSignOut : msg
    }
    -> Html msg
view options =
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ class "navbar-brand", Route.Path.href Route.Path.Home_ ] [ text "conduit" ]
            , ul [ class "nav navbar-nav pull-xs-right" ] <|
                case options.user of
                    Just _ ->
                        List.concat
                            [ List.map (viewLink options.currentRoutePath) <|
                                [ ( "Home", Route.Path.Home_ )
                                , ( "New Article", Route.Path.Editor )
                                , ( "Settings", Route.Path.Settings )
                                ]
                            , [ li [ class "nav-item" ]
                                    [ a
                                        [ class "nav-link"
                                        , Events.onClick options.onSignOut
                                        ]
                                        [ text "Sign out" ]
                                    ]
                              ]
                            ]

                    Nothing ->
                        List.map (viewLink options.currentRoutePath) <|
                            [ ( "Home", Route.Path.Home_ )
                            , ( "Sign in", Route.Path.Login )
                            , ( "Sign up", Route.Path.Register )
                            ]
            ]
        ]


viewLink : Path -> ( String, Path ) -> Html msg
viewLink currentRoutePath ( label, routePath ) =
    li [ class "nav-item" ]
        [ a
            [ class "nav-link"
            , classList [ ( "active", currentRoutePath == routePath ) ]
            , Route.Path.href routePath
            ]
            [ text label ]
        ]
