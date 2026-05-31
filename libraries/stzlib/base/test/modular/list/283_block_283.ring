# Narrative
# --------
# #ring #perf #narration
#
# Extracted from stzlisttest.ring, block #283.

load "../../../stzBase.ring"


StartProfiler()

# When searching for elements in a list, always start by
# checking if you can use the global @Find...() functions
# provided by Softanza, before using an stzList object.

# These functions can be used when the items you’re looking for
# are either numbers or lists. Otherwise, the use of stzList is necessary.

# As you’ll see in this example and the one that follows,
# choosing the right approach can lead to significant performance gains.

# In this example, we use the @Find... global functions
# (execution time: 0.48 second(s) in Ring 1.22)

# In the following example, we perform the same task
# using an stzList object (execution time: 12.14 seconds)


# Fabricating a large list of strings (more then 150K items)

	aLargeListOfStr = [ "_", "_" ]
	for i = 1 to 100_000
		aLargeListOfStr + "_"
	next
	
	aLargeListOfStr + "♥" + "_" + "_" + "♥"
	
	for i = 1 to 50_000
		aLargeListOfStr + "_"
	next i

# Finding the first occurrence of "♥" in the list

	? @FindFirst(aLargeListOfStr, "♥")
	#--> 100003

# Finding the last occurrence of "♥" in the list

	? @FindLast(aLargeListOfStr, "♥")
	#--> 100006

# Finding the 2nd occurrence of "♥" in the list

	? @FindNthST(aLargeListOfStr, 2, "♥", :StartingAt = 1)
	#--> 100006

# Finding the next occurrence of "♥" in the list starting at position 3

	? @FindNext(aLargeListOfStr, "♥", :StartingAt = 3)
	# 100003

# Finding the next 2nd occurrence of "♥" in the list starting at position 3

	? @FindNthNext(aLargeListOfStr, 2, "♥", :StartingAt = 3)
	#--> 100006

pf()
# Executed in 0.53 second(s) in Ring 1.22
