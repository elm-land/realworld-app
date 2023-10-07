module Api.Article.Comment exposing
    ( Comment
    , decoder
    , delete
    )

{-|

@docs Comment
@docs decoder
@docs delete

-}

import Api
import Api.Data exposing (Data)
import Api.Token exposing (Token)
import Iso8601
import Json.Decode as Json
import Time


type alias Comment =
    { id : Int
    , createdAt : Time.Posix
    , updatedAt : Time.Posix
    , body : String
    , author : Api.Profile
    }


decoder : Json.Decoder Comment
decoder =
    Json.map5 Comment
        (Json.field "id" Json.int)
        (Json.field "createdAt" Iso8601.decoder)
        (Json.field "updatedAt" Iso8601.decoder)
        (Json.field "body" Json.string)
        (Json.field "author" Api.decodeProfile)



-- ENDPOINTS


delete :
    { token : Token
    , articleSlug : String
    , commentId : Int
    , onResponse : Data Int -> msg
    }
    -> Cmd msg
delete options =
    Api.Token.delete (Just options.token)
        { url =
            "https://conduit.productionready.io/api/articles/"
                ++ options.articleSlug
                ++ "/comments/"
                ++ String.fromInt options.commentId
        , expect =
            Api.Data.expectJson options.onResponse (Json.succeed options.commentId)
        }
