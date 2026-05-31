# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #430.

load "../../../stzBase.ring"


? StzListQ([ "q", "r", [ 2, 1 ] ]).ToCode()
#--> [ "q", "r", [ 2, 1 ] ]

# Or you can use this alternative short form:

? @@( [ "q", "r", [ 2, 1 ] ] ) + NL # same as ComputableForm()
#--> [ "q", "r", [ 2, 1 ] ]

pf()
# Executed in almost 0 second(s).
