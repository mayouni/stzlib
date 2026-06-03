# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #82.
#ERR Error (R11) : Error in class name, class not found: stzlistofstrings

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "tom", "sam", "dan" ])
? @@(o1.Unicodes())
#--> [ [ 116,111,109 ],[ 115,97,109 ],[ 100,97,110 ] ]


pf()
# Executed in 0.07 second(s)
