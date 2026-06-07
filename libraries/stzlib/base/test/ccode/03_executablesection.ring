# Narrative
# --------
# pr()
#
# Extracted from stzccodetest.ring, block #3.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? StzCCodeQ('{ This[ @i + 3 ] = This[@i + 1] }').ExecutableSection()
#--> [ 1, -3 ]

pf()
# Executed in 0.05 second(s) in Ring 1.23
# Executed in 0.07 second(s) in Ring 1.21
