# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #34.

load "../../stzBase.ring"


? QQ(1:100_000).NRandomNumbers(3)
#--> [100_000, 100_000, 100_000]
#--> [100_000, 99_999, 100_000]
#--> [99_999, 99_999, 99_999]

pf()
# Executed in 0.62 second(s)
