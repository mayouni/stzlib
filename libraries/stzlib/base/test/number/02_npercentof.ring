# Narrative
# --------
#
# Extracted from stznumbertest.ring, block #2.

load "../../stzBase.ring"

pr()

nAnnualGain = 20500

? NPercentOf(10, nAnnualGain)
#--> 2050

# Or Better
? 10PercentOf(nAnnualGain)

# Or even more generally
? Q(10).PercentOf(nAnnualGain)

? Q(25).Percent()
#--> 0.25

pf()
# Executed in almost 0 second(s) in Ring 1.23
