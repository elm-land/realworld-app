module Api.Article.Comment exposing
    ( Comment
    , decoder
    )

{-|

@docs Comment
@docs decoder

-}

import Api
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
