# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #284.
#ERR TIMEOUT (>15s)

load "../../stzBase.ring"

pr()

# Fabricating a large list of strings (more then 150K items)

	aLargeListOfStr = [ "_", "_" ]
	for i = 1 to 100_000
		aLargeListOfStr + "_"
	next
	
	aLargeListOfStr + "♥" + "_" + "_" + "♥"
	
	for i = 1 to 50_000
		aLargeListOfStr + "_"
	next i


# Find "♥" in several ways
	o1 = new stzList(aLargeListOfStr)

	? o1.NumberOfOccurrence("♥")
	#--> 2

	? o1.FindFirst("♥")
	#--> 100003
	
	? o1.FindLast("♥")
	#--> 100006

	? o1.FindNth(2, "♥")
	#--> 100006

	? o1.FindNext("♥", :StartingAt = 3)
	#--> 999999

	? o1.FindNthNext(2, "♥", :StartingAt = 3)
	#--> 100006

StopProfiler()

pf()
# Executed in 5.75 second(s) in Ring 1.22
# Executed in 11.90 second(s) in Ring 1.21
# Executed in 31.56 second(s) in Ring 1.17
