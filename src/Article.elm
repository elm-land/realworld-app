module Article exposing (Listing, updateListing)

import Api


type alias Listing =
    { articles : List Api.Article
    , page : Int
    , totalPages : Int
    }


updateListing : Api.Article -> Listing -> Listing
updateListing article listing =
    let
        articles : List Api.Article
        articles =
            List.map
                (\a ->
                    if a.slug == article.slug then
                        article

                    else
                        a
                )
                listing.articles
    in
    { listing | articles = articles }
