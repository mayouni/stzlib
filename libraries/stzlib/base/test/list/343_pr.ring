# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #343.

load "../../stzBase.ring"


? Q([ "ring", "php", "python" ]).Are([ :Lowercase, :Strings ])
#--> TRUE

? Q([ "ABC", "DEF", "GHI" ]).Are([ :Uppercase, :Strings ])
#--> TRUE

pf()
# Executed in 0.11 second(s).
