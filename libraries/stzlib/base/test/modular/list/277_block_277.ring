# Narrative
# --------
# #perf
#
# Extracted from stzlisttest.ring, block #277.

load "../../../stzBase.ring"

StartProfiler()

# Fabricating a large list of strings (more then 150K items)

	aLargeListOfStr = [ "_", "_", "♥" ]
	for i = 1 to 100_000
		aLargeListOfStr + "_"
	next
	
	aLargeListOfStr + "♥" + "_" + "_" + "♥"
	
	for i = 1 to 50_000
		aLargeListOfStr + "_"
	next i
	
	aLargeListOfStr + "♥" + "_" + "_" + "♥"
	
	for i = 1 to 10
		aLargeListOfStr + "_"
	next i
# 

# Finding previous "♥"

	o1 = new stzList(aLargeListOfStr)

	? o1.FindPrevious("♥", :StartingAt = 5)
	#--> 3

	? o1.FindNthPrevious(2, "♥", :StartingAt = 120_000)
	#--> 100004

	? o1.FindNthPrevious(3, "♥", :StartingAt = 150_000)
	#--> 3

	? o1.FindPrevious("♥", :StartingAt = 150_000)
	#--> 100007

StopProfiler()
# Executed in 2.15 second(s) in Ring 1.21
# Executed in 7.51 second(s) in Ring 1.20
