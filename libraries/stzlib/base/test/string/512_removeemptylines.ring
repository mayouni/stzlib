# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #512.
#ERR Error (R14) : Calling Method without definition: removeemptylinesq

load "../../stzBase.ring"

pr()

o1 = new stzString("

.;1;.;.;.
1;2;3;4;5
.;3;.;.;.
.;4;.;.;.
.;5;.;.;.  " )

? o1.RemoveEmptyLinesQ().Content()
#-->
# .;1;.;.;.
# 1;2;3;4;5
# .;3;.;.;.
# .;4;.;.;.
# .;5;.;.;.  

pf()
# Executed in 0.01 second(s).
