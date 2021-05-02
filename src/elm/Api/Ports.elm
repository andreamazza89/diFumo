port module Api.Ports exposing
    ( AwsCredentials
    , awsDataReceived
    , emptyCredentials
    , failedToFetchAwsData
    , fetchAwsData
    )

import Json.Decode as Json
import Region exposing (Region)


type alias AwsCredentials =
    { accessKeyId : String
    , secretAccessKey : String
    , sessionToken : String
    , region : Region
    }


type alias AwsCredentials_ =
    { accessKeyId : String
    , secretAccessKey : String
    , sessionToken : String
    , region : String
    }


emptyCredentials : AwsCredentials
emptyCredentials =
    { accessKeyId = ""
    , secretAccessKey = ""
    , sessionToken = ""
    , region = Region.EuWest1
    }


port awsDataReceived : (Json.Value -> msg) -> Sub msg


fetchAwsData : AwsCredentials -> Cmd msg
fetchAwsData creds =
    fetchAwsData_
        { accessKeyId = creds.accessKeyId
        , secretAccessKey = creds.secretAccessKey
        , sessionToken = creds.sessionToken
        , region = Region.id creds.region
        }


port fetchAwsData_ : AwsCredentials_ -> Cmd msg


port failedToFetchAwsData : (String -> msg) -> Sub msg
