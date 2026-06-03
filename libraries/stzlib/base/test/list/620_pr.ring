# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #620.

load "../../stzBase.ring"


o1 = new stzList([ 1, "ring", 3, "python", 5, "ruby" ])
? @@( o1.YieldAtWXT([ 2, 4, 6 ], 'isString(@item)', 'upper(@item)') )
#--> [ "RING", "PYTHON", "RUBY" ]

pf()
# Executed in 0.12 second(s) in Ring 1.22
