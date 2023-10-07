module Api.Article.Tag exposing (Tag, list)

import Api
import Api.Data exposing (Data)
import Http
import Json.Decode as Json


type alias Tag =
    String


list : { onResponse : Data (List String) -> msg } -> Cmd msg
list options =
    -- TODO
    -- Api.getTags {}
    Http.get
        { url = "https://conduit.productionready.io/api/tags"
        , expect =
            Api.Data.expectJson options.onResponse
                (Api.decodeTagsResponse |> Json.map .tags)
        }
