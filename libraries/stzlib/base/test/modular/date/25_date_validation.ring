# Narrative
# --------
# Date validation
#
# Extracted from stzdatetest.ring, block #25.

load "../../../stzBase.ring"


pr()

oDate = StzDateQ("32/13/2024")  # Invalid date
#--> Cannot parse date string: 32/13/2024

pf()
# Executed in almost 0 second(s) in Ring 1.23
