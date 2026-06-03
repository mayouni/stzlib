# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #209.

load "../../stzBase.ring"

pr()

? StzCCodeQ('NOT isNumber( This[@i + 1] )').ExecutableSection()
#--> [1, -1]

pf()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.12 second(s) in Ring 1.18
