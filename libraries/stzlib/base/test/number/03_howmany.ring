# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #3.
#ERR Error (R14) : Calling Method without definition: howmany

load "../../stzBase.ring"

pr()

? Q(120602061.1).HowMany(0)
#--> 4
#~> Bacause decimals() = 2 by default and then
#   120602061.1 is actually 120602061.10

? Q("120602061.1").HowMany("0")
#--> 3

? Q(120602061.10).HowMany(1)
#--> 3

? Q(120602061.1).HowMany(20)
#--> 2

? Q(120602061.1).HowMany("06")
#--> 2

pf()
# Executed in 0.01 second(s) in Ring 1.21
