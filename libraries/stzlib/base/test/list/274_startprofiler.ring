# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #274.

load "../../stzBase.ring"


# Fabricating a large list of strings (more then 150K items)

	aLargeListOfStr = ["_", "_", "♥"]
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

# Finding next "♥"

	o1 = new stzList(aLargeListOfStr)

	? o1.FindNext("♥", :StartingAt = 100_000)
	#--> 100004

	? o1.FindNth(3, "♥")
	#--> 100007

	? o1.FindNthNext(2, "♥", :StartingAt = 2)
	#--> 100004
	
	? o1.FindNthNext(3, "♥", :StartingAt = 12_000)
	#--> 150008

StopProfiler()
# Executed in 2.70 second(s) in Ring 1.21
# Executed in 3.51 second(s) in Ring 1.19
# Executed in 7.55 second(s) in Ring 1.17
