# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #432.

load "../../../stzBase.ring"


? ListContains([], NULL)
#--> FALSE

? ListContains([NULL], NULL)
#--> TRUE

? IsListOfStrings([])
#--> FALSE

? IsListOfStrings([ NULL, NULL, NULL])
#--> TRUE

pf()
# Executed in 0.01 second(s).
