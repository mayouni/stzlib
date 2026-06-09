# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #618.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, "ring", 2, "python", 3, "ruby" ])
? @@( o1.YieldWXT('isString(@item)', 'upper(@item)') )
#--> [ "RING", "PYTHON", "RUBY" ]

pf()
# Executed in 0.15 second(s) in Ring 1.22
