module Node.EcsTask exposing (..)


type EcsTask
    = EcsTask
        { id : EcsTaskId
        , group : String
        }


type EcsTaskId
    = EcsTaskId String


id : EcsTask -> EcsTaskId
id (EcsTask ecs) =
    ecs.id


equals : EcsTask -> EcsTask -> Bool
equals ecs otherEcs =
    id ecs == id otherEcs


idAsString (EcsTask ecs) =
    ecs.group


canAccessInternet : EcsTask -> Bool
canAccessInternet ecsTask =
    -- TODO : figure out how we can tell if a task is publicly accessible or not
    True


type alias Config a =
    { a
        | id : String
        , group : String
    }


build : Config a -> EcsTask
build config =
    EcsTask
        { id = EcsTaskId config.id
        , group = config.group
        }
