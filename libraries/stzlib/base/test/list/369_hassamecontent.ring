# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #369.
#ERR Error (R14) : Calling Method without definition: hassamecontent

load "../../stzBase.ring"

pr()

? Q([ "I", "B", "M" ]).HasSameContent( :As = [ "B", "M", "I" ] )
? Q([ "I", "B", "M" ]).HasSameContentCS( :As = [ "b", "m", "i" ], :CS = FALSE )

pf()
# Executed in almost 0 second(s).
