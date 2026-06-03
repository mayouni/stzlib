# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #208.

load "../../stzBase.ring"


? StzCCodeQ('Q(@NextItem).IsNotANumber()').Transpiled()
#--> Q( This[@i + 1] ).IsNotANumber(  )

pf()
# Executed in 0.07 second(s) in Ring 1.21
# Executed in 0.30 second(s) in Ring 1.17
