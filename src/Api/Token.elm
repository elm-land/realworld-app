module Api.Token exposing
    ( Token
    , delete
    )

{-|

@docs Token
@docs delete

-}

import Http


type alias Token =
    String



-- HTTP HELPERS


delete :
    Maybe Token
    ->
        { url : String
        , expect : Http.Expect msg
        }
    -> Cmd msg
delete =
    request "DELETE" Http.emptyBody


request :
    String
    -> Http.Body
    -> Maybe Token
    ->
        { options
            | url : String
            , expect : Http.Expect msg
        }
    -> Cmd msg
request method body maybeToken options =
    Http.request
        { method = method
        , headers =
            case maybeToken of
                Just token ->
                    [ Http.header "Authorization" ("Token " ++ token) ]

                Nothing ->
                    []
        , url = options.url
        , body = body
        , expect = options.expect
        , timeout = Just (1000 * 60) -- 60 second timeout
        , tracker = Nothing
        }
