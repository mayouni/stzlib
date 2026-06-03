# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #51.

load "../../stzBase.ring"

pr()

? StzListOfNumbersQ( 12:22 ).SortingOrder()
#--> :Ascending

? StzListOfNumbersQ( 17:8 ).SortingOrder()
#--> :Descending

pf()
# Executed in 0.15 second(s)
