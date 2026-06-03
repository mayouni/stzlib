# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #616.
#ERR Error (R3) : Calling Function without definition: previousnthmarquer

load "../../stzBase.ring"

pr()

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? PreviousNthMarquer(3, :StartingAt = 50)
	#--> #1

	? FindPreviousNthMarquer(3, :StartingAt = 50) # or  PreviousNthMarquerPosition(3, :StartingAt = 50)
	#--> 12

	? @@( PreviousNthMarquerZ(3, :StartingAt = 50) ) # or PreviousNthMarquerAndItsPosition(3, :StartingAt = 50)
	#--> [ "#1", 12 ]

	#TODO : Add these functions	
	# 	? NthMarquerZ(n)
	# 	? NthMarquerZZ(n)
	
	# 	? NextNthMarquerZZ(n, nStart)
	# 	? PreviousNthMarquerZZ(n, nStart)
}

pf()
# Executed in 0.03 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 2.02 second(s) in Ring 1.18
