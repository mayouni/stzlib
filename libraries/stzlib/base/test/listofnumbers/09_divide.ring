# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #9.

load "../../stzBase.ring"

pr()

# Multiple calculation

? Divide([ 12, 2, 3 ])
#--> 2

? Substruct([ 10, 2, 3 ])
#--> 5

? Multiply([ 10, 2, 3 ])
#--> 60

? Sum([ 10, 2, 4 ]) + NL
#--> 16

#-- Cumulated

? DivideXT([ 12, 2, 3 ]) # Or DivideAndCumulate
#--> [ 12, 6, 2 ]

? SubstructXT([ 10, 2, 3 ])
#--> [ 10, 8, 5 ]

? MultiplyXT([ 10, 2, 3 ])
#--> [ 10, 20, 60 ]

? SumXT([ 10, 2, 4 ])
#--> [ 10, 12, 16 ]

pf()
# Executed in 0.01 second(s)
