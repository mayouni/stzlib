# Narrative
# --------
# @perf
#
# Extracted from stzlisttest.ring, block #13.
#ERR TIMEOUT (>15s)

load "../../stzBase.ring"


pr()

# Constructing a large deep list of 1 million items
# Items are of all types : numbers, strings, lists and objects
# Some items are deep up to 3 levels (a list in list in list!)

aLarge = 1 : 300_000

aList = [ "A" : "Z", [ 10 : 12, [ "_", "_"] ], [ NullObject(), TRUEObject() ] ]
for j = 1 to 20_000
	for i = 1 to len(aList)
		aLarge + aList[i]
	next
next

for i = 100_001 to 140_000
	aLarge + i
next

? len( Flatten(aLarge) )
#--> 1_000_000

# The code above is 9X times more performant in Ring 1.21 then Ring 1.17

? SpeedUpX(34.33, 3.81)
#--> 9.01

pf()
# Executed in 3.81 second(s) in Ring 1.21 (64 bits)
# Executed in  5.75 second(s) in Ring 1.19 (64 bits)
# Executed in  6.55 second(s) in Ring 1.19 (32 bits)
# Executed in 16.13 second(s) in Ring 1.18
# Executed in 34.33 second(s) in Ring 1.17
