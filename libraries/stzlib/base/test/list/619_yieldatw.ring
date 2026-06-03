# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #619.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, "ring", 3, "python", 5, "ruby" ])
? @@( o1.YieldAtW([ 2, 4, 6 ], 'isString(This[@i])', 'upper(this[@i])') )
#--> [ "RING", "PYTHON", "RUBY" ]

pf()
# Executed in 0.06 second(s) in Ring 1.22
