module Components.UserForm exposing (Field, view)

import Api.Data exposing (Data)
import Api.User exposing (User)
import Components.ErrorList
import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, type_, value)
import Html.Events as Events
import Route.Path exposing (Path)


type alias Field msg =
    { label : String
    , type_ : String
    , value : String
    , onInput : String -> msg
    }


view :
    { user : Data User
    , label : String
    , onFormSubmit : msg
    , alternateLink : { label : String, route : Path }
    , fields : List (Field msg)
    }
    -> Html msg
view options =
    div [ class "auth-page" ]
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-6 offset-md-3 col-xs-12" ]
                    [ h1 [ class "text-xs-center" ] [ text options.label ]
                    , p [ class "text-xs-center" ]
                        [ a [ Route.Path.href options.alternateLink.route ]
                            [ text options.alternateLink.label ]
                        ]
                    , case options.user of
                        Api.Data.Failure reasons ->
                            Components.ErrorList.view reasons

                        _ ->
                            text ""
                    , form [ Events.onSubmit options.onFormSubmit ] <|
                        List.concat
                            [ List.map viewField options.fields
                            , [ button [ class "btn btn-lg btn-primary pull-xs-right" ] [ text options.label ] ]
                            ]
                    ]
                ]
            ]
        ]


viewField : Field msg -> Html msg
viewField options =
    fieldset [ class "form-group" ]
        [ input
            [ class "form-control form-control-lg"
            , placeholder options.label
            , type_ options.type_
            , value options.value
            , Events.onInput options.onInput
            ]
            []
        ]
