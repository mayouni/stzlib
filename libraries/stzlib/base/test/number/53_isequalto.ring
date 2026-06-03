# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #53.

load "../../stzBase.ring"

pr()

? Q(5.12).IsEqualTo(5.1200000000000001)
#--> TRUE

# Because the current round on the program is 2, as defined by default in Ring.
# When Ring rounds the long number provided to 2, it will become 5.12

? Q(5.12).IsEqualTo("5.1200000000000001")
#--> TRUE

# But if we use the round that reads the very last 1 in the decimal part,
# the two numbers will be identified as beeing different:

? Q(5.12).IsEqualTo([ 5.1200000000000001, :Round = 16 ])
#--> FALSE

pf()
# Executed in 0.02 second(s) in Ring 1.21
