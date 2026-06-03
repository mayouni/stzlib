# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #286.

load "../../stzBase.ring"

pr()

# Fabricating a list of strings (more then 10K items)

	aLargeListOfStr = []
	for i = 1 to 5_000
		aLargeListOfStr + "_"
	next
	
	aLargeListOfStr + "HI" + "ME"
	
	for i = 1 to 5_000
		aLargeListOfStr + "_"
	next i
	
	aLargeListOfStr + "HI" + "YOU"
	
	for i = 1 to 10
		aLargeListOfStr + "_"
	next i

# Removing dupicates

	o1 = new stzList(aLargeListOfStr)

	? ShowShort( o1.FindDuplicates() )
	#--> [ 2, 3, 4, "...", 150012, 150013, 150014 ]
	# Executed in 0.26 seconds

	o1.RemoveDuplicates()
	? ShowShort( o1.Content() )

StopProfiler()

pf()
# Executed in 15.85 second(s) in Ring 1.21
