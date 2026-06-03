# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #272.
#ERR TIMEOUT (>15s)

load "../../stzBase.ring"

pr()

# Constructing the large list (+1M items, the to-be-found item is a list (1:3),
# and it exists in the beginning and the end of the large list)

	aList = [ "A", 10, "A", 1:3, 20, 1:3, 1:3, "B" ]
	aLarge = aList
	
	for i = 1 to 1_000_000
		aLarge + "..."
	next
	for i = 1 to 8
		aLarge + aList[i]
	next
	# ElapsedTime : 0.48 seconds

# Turning param chek off (better performance)

	CheckParamsOff()

# Doing the job

	o1 = new stzList(aLarge)
	? o1.FindNth(4, 1:3)
	#--> 1_000_012

pf()
# Executed in 45.05 second(s)
