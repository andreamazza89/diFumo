module Fixtures.NetworkACL exposing (allowAll, blockAll)

import Cidr
import Port
import Protocol
import Vpc.NetworkACL as NetworkACL exposing (Action(..), NetworkACL, Rule)


allowAll : NetworkACL
allowAll =
    NetworkACL.build
        { ingressRules = [ allowAll_ ]
        , egressRules = [ allowAll_ ]
        }


blockAll : NetworkACL
blockAll =
    NetworkACL.build
        { ingressRules = []
        , egressRules = []
        }


allowAll_ : Rule
allowAll_ =
    { cidr = Cidr.everywhere
    , protocol = Protocol.all
    , fromPort = Port.first
    , toPort = Port.last
    , action = Allow
    , ruleNumber = 1
    }
