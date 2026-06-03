# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #92.
#ERR Error (R14) : Calling Method without definition: stringifyandreplace

load "../../stzBase.ring"

pr()

o1 = new stzList([ "--_--", [ 12, "--_--", 10], "--_--", 9 ])
o1.StringifyAndReplace("_", "♥")
? @@( o1.Content() )
#--> [ "--♥--", '[ 12, "--♥--", 10 ]', "--♥--", "9" ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.03 second(s) in Ring 1.19
