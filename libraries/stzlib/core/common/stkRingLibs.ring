
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  LOADING NECESSARY RING LIBS AND ENGINE BRIDGES      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

load "stdlibcore.ring"

# Load Core Engine bridge (string + char)
# The Engine replaces Qt -- no qtcore.ring, no Ring extensions.

$cEngineDir = exefolder() + "/../libraries/stzlib/engine"

load "../../engine/stk_string.ring"
