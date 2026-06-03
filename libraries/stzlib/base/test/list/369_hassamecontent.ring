# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #369.

load "../../stzBase.ring"

pr()

? Q([ "I", "B", "M" ]).HasSameContent( :As = [ "B", "M", "I" ] )
? Q([ "I", "B", "M" ]).HasSameContentCS( :As = [ "b", "m", "i" ], :CS = FALSE )

pf()
# Executed in almost 0 second(s).
