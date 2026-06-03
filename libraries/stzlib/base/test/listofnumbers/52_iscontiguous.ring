# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #52.

load "../../stzBase.ring"

pr()

? StzListOfNumbersQ( 12:22 ).IsContiguous()
#--> TRUE

? StzListOfNumbersQ( 17:8 ).IsContiguous()
#--> TRUE

? StzListOfNumbersQ([10, 12, 18]).IsContiguous()
#--> FALSE

? StzListOfNumbersQ([10, 11, 10]).IsContiguous()
#--> FALSE

pf()
# Executed in 0.03 second(s)
