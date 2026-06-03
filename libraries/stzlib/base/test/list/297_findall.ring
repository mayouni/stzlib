# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #297.

load "../../stzBase.ring"

pr()

# Fabricating a large list of strings (more then 150K items)

	aLargeListOfStr = [ [ "ME", "YOU"] ]

	for i = 1 to 100_000
		aLargeListOfStr + "_"
	next
	
	aLargeListOfStr + "HI" + [ "ME", "YOU"]
	
	for i = 1 to 50_000
		aLargeListOfStr + "_"
	next i
	
	aLargeListOfStr + "HI" + "YOU"
	
	for i = 1 to 10
		aLargeListOfStr + "_"
	next i

	aLargeListOfStr + [ "ME", "YOU"]

# Removing dupicates

	o1 = new stzList(aLargeListOfStr)

	? o1.FindAll([ "ME", "YOU"])
	#-->  [1, 100003, 150016]
	
StopProfiler()

pf()
# Executed in 0.67 second(s) in Ring 1.21
# Executed in 9.01 second(s) in Ring 1.18
