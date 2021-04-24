module Element.Scale exposing
    ( edges
    , large
    , medium
    , small
    , veryLarge
    , verySmall
    )


verySmall : number
verySmall =
    5


small : number
small =
    10


medium : number
medium =
    21


large : number
large =
    42


veryLarge : number
veryLarge =
    84



-- Edges (this should probably live somewhere else)


edges :
    { top : number
    , right : number
    , bottom : number
    , left : number
    }
edges =
    { top = 0
    , right = 0
    , bottom = 0
    , left = 0
    }
