module Utils.NonEmptyList exposing (NonEmptyList, fromList, head, tail)

-- Non Empty List


type NonEmptyList a
    = NonEmptyList
        { first : a
        , rest : List a
        }



-- Query


head : NonEmptyList a -> a
head (NonEmptyList { first }) =
    first


tail : NonEmptyList a -> List a
tail (NonEmptyList { rest }) =
    rest



-- Build


fromList : List a -> Result String (NonEmptyList a)
fromList xs =
    case xs of
        [] ->
            Err "List cannot be empty"

        y :: ys ->
            Ok (NonEmptyList { first = y, rest = ys })
