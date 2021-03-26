port module Api.Ports exposing
    ( AwsCredentials
    , awsDataReceived
    , emptyCredentials
    , fetchAwsData
    )

import Json.Decode as Json


type alias AwsCredentials =
    { accessKeyId : String
    , secretAccessKey : String
    }


emptyCredentials : AwsCredentials
emptyCredentials =
    { accessKeyId = ""
    , secretAccessKey = ""
    }


port awsDataReceived : (Json.Value -> msg) -> Sub msg


port fetchAwsData : AwsCredentials -> Cmd msg
