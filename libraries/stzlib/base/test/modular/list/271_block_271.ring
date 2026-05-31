# Narrative
# --------
# #narration #perf #ring
#
# Extracted from stzlisttest.ring, block #271.

load "../../../stzBase.ring"


pr()

# Constructing the large list

	aList = [ "A", 10, "A", "♥", 20, 1:3, "♥", "B" ]
	aLarge = aList
	
	for i = 1 to 1_000_000
		aLarge + "..."
	next

	for i = 1 to 8
		aLarge + aList[i]
	next


# Doing the job

	CheckParamsOff()

	? @FindNth(aLarge, 4, "♥")
	#--> 1000015

# Here we use an enhance Ring-find()-based global function.
# It's far more perforant then using a stzLits object like in:

#	o1 = new stzList(aLarge)
#	? o1.FindNth(4, "♥")

# In this case, execution time exceeds 42 seconds!

#NOTE
# You should always prefer this option when the items you are
# goinf to find are findable by Ring (numbers or strings).

pf()
# Executed in 0.79 second(s).
