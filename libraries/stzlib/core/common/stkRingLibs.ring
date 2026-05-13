
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  LOADING NECESSARY RING LIBS AND ENGINE BRIDGES      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

load "stdlibcore.ring"

# Load Core Engine bridge (string + char)
# The Engine replaces Qt -- no qtcore.ring, no Ring extensions.

$cEnginePath = exefolder() + "/../libraries/stzlib/engine"

chdir($cEnginePath)
load "stk_string.ring"
chdir(exefolder())
