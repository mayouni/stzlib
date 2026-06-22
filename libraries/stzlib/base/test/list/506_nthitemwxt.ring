# Narrative
# --------
# Retrieves the Nth item of a list that satisfies an anonymous predicate.
#
# NthItemWF walks the list keeping only items for which the supplied
# function returns TRUE, then returns the Nth survivor (1-based). Here
# the predicate keeps lowercase strings, so the uppercase "CAMARADE" is
# skipped: the qualifying items are "ami", "coupain", "compagon", and
# asking for the 3rd one yields "compagon". The WF suffix marks the
# anonymous-function (With Function) variant of the NthItem family.
#
# Extracted from stzlisttest.ring, block #506.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ami", "coupain", "CAMARADE", "compagon" ])
? o1.NthItemWF(3, func x { return isString(x) and Q(x).IsLowercase() } )
#--> "compagon"

pf()
# Executed in 0.15 second(s).
