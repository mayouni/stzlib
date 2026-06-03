# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #18.
#ERR TIMEOUT (>15s)

load "../../stzBase.ring"

pr()

? RandomNumberGreaterThan(12)
#--> 999_999_999_999_995
#--> 999_999_999_999_990
#--> 999_999_999_999_988
#--> 999_999_999_999_991
#--> 999_999_999_999_992

pf()
# Executed in 0.03 second(s)
