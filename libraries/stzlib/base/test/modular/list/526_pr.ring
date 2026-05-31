# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #526.

load "../../../stzBase.ring"


o1 = new stzList( [ "1", "2", [ 1, [ "x" ], 2 ],  "3" ] )

? o1.ToCode()
#--> '[ "1", "2", [ 1, [ "x" ], 2 ],  "3" ]'

pf()
# Executed in almost 0 second(s).
