# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #482.

load "../../../stzBase.ring"


? StzCCodeQ('{ This[@i - 3 ] = This[ @i + 3 ] }').ExecutableSection()
#--> [4, -3]

pf()
# Executed in 0.07 second(s) in Ring 1.22
