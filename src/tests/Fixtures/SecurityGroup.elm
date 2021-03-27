module Fixtures.SecurityGroup exposing
    ( allowAllInOut
    , allowNothing
    )

import Cidr
import Port
import Protocol
import Vpc.SecurityGroup as SecurityGroup exposing (SecurityGroup)



-- SecurityGroup test fixtures


allowAllInOut : SecurityGroup
allowAllInOut =
    SecurityGroup.build "some-security-group-id" allowAll allowAll


allowNothing : SecurityGroup
allowNothing =
    SecurityGroup.build "some-security-group-id" [] []


allowAll : List SecurityGroup.Rule_
allowAll =
    [ { forProtocol = Protocol.all
      , fromPort = Port.first
      , toPort = Port.last
      , cidrs = [ Cidr.everywhere ]
      }
    ]
