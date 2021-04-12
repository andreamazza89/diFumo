module Utils.Dict exposing (updateList)

import Dict


updateList : comparable -> a -> Dict.Dict comparable (List a) -> Dict.Dict comparable (List a)
updateList key item dict =
    Dict.update key (addToListOrCreate item) dict


addToListOrCreate : a -> Maybe (List a) -> Maybe (List a)
addToListOrCreate item =
    Maybe.map (addToList item)
        >> Maybe.withDefault (newList item)


addToList : a -> List a -> Maybe (List a)
addToList item =
    (::) item >> Just


newList : a -> Maybe (List a)
newList item =
    Just [ item ]
