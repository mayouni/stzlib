# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #293.

load "../../../stzBase.ring"


# Fabricating a large list

	aLargeList = 1 : 100_000

	aMyList = [ 1, 2,
		    [ "A", "B", "C", "عربي", "كلام", "D" ],
		    3, 4, 5,
		    [ "A", "B", "C", "عربي", "كلام", "D" ],
		    6, 7,
		    [ "A", "B", "C", "عربي", "كلام", "D" ]
	]

	for i = 1 to len(aMyList)
		aLargeList + aMyList[i]
	next

# Finding the first occurrence
	o1 = new stzList(aLargeList)

	? o1.FindFirst([ "A", "B", "C", "عربي", "كلام", "D" ])
	#--> 100003

# Finding the last occurrence

	? o1.FindLast([ "A", "B", "C", "عربي", "كلام", "D" ])
	#--> 100010

# Finding the 2nd occurrence

	? o1.FindNth(2, [ "A", "B", "C", "عربي", "كلام", "D" ])
	#--> 100007

StopProfiler()
# Executed in 1.32 second(s) in Ring 1.21
# Executed in 8.50 second(s) in Ring 1.18
