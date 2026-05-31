# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #296.

load "../../../stzBase.ring"


# Fabricating a large list of strings (more then 150K items)

	aLargeListOfStr = []
	for i = 1 to 100_000
		aLargeListOfStr + "_"
	next
	
	aLargeListOfStr + "HI" + "ME"
	
	for i = 1 to 50_000
		aLargeListOfStr + "_"
	next i
	
	aLargeListOfStr + "HI" + "YOU"
	
	for i = 1 to 10
		aLargeListOfStr + "_"
	next i

# Removing dupicates

	o1 = new stzList(aLargeListOfStr)

	? o1.NumberOfOccurrence("_")
	#--> 150010
	
StopProfiler()
# Executed in 3.36 second(s)
