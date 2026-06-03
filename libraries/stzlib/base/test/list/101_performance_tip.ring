# Narrative
# --------
# PERFORMANCE TIP
#
# Extracted from stzlisttest.ring, block #101.

load "../../stzBase.ring"


pr()

# ComputableForm() function, abreviated with @@(), is not intended to
# be used inside large loops like this:

aList = ["_", "_", "♥"]

for i = 1 to 100_000
	@@(aList)
next
#--> Takes more then 20 seconds! (in Ring 1.17)
#--> Takes more then 10 seconds! (in Ring 1.19)

# Instead, you shoud do this:

cList = @@(aList)
for i = 1 to 100_000
	cList
next
# Takes only 0.05 seconds!
#--> 400 times more performant.

pf()
# Executed in 0.03 second(s) in Ring 1.24
# Executed in 21.3 second(s) in Ring 1.17
