# Narrative
# --------
# YIELDER
#
# Extracted from stzlisttest.ring, block #617.

load "../../../stzBase.ring"


pr()

o1 = new stzList([ 1, "ring", 2, "python", 3, "ruby" ])
? @@( o1.YieldW('isString(This[@i])', 'upper(this[@i])') )
#--> [ "RING", "PYTHON", "RUBY" ]

pf()
# Executed in 0.03 second(s) in Ring 1.24
# Executed in 0.06 second(s) in Ring 1.22
