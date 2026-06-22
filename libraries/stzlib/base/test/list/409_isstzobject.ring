# Narrative
# --------
# Shows the global type-guard helpers @IsStzObject() and @IsStzList()
# answering questions about a live stzList instance.
#
# Softanza objects are plain Ring objects, so a caller can't rely on
# Ring's bare isObject(). The @-prefixed global guards bridge that gap:
# @IsStzObject() returns TRUE for any Softanza wrapper, while the
# narrower @IsStzList() confirms the value is specifically a stzList.
# Built on a list of [ 1, 2, 3 ], both guards return TRUE, which is the
# canonical way to branch on Softanza types before dispatching list ops.
#
# Extracted from stzlisttest.ring, block #409.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3 ])

? @IsStzObject(o1)
#--> TRUE

? @IsStzList(o1)
#--> TRUE

pf()
# Executed in 0.02 second(s).
