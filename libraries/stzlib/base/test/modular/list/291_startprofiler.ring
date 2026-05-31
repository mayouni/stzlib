# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #291.

load "../../../stzBase.ring"


# Fabricating a large list

	aLargeList = 1:100_000
	aLargeList + "A":"C" + "A":"C"
	
	aMyList = [ "_", "_", "A":"C", "_", "_", "A":"C", "_", "_", "A":"C", "_" ]
	for i = 1 to len(aMyList)
		aLargeList + aMyList[i]
	next

	o1 = new stzList(aLargeList)
	? o1.FindNth(2, "A":"C")
	#--> 100002

	? o1.FindNext("A":"C", :StartingAt = 89_000)
	#--> 100001

	? o1.FindNthPrevious(3, "A":"C", :StartingAt = 100_010)
	#--> 100002

StopProfiler()
# Executed in 1.04 second(s) in Ring 1.21
# Executed in 8.38 second(s) in Ring 1.19
