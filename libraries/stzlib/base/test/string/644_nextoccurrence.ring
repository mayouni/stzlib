# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #644.
#ERR Error (R19) : Calling function with less number of parameters

load "../../stzBase.ring"

pr()

StzStringQ("12500;NAME;10;0") {

	? NextOccurrence( :Of = ";", :StartingAt = 1 )
	#--> 6

	? NextNthOccurrence( 2, :Of = ";", :StartingAt = 5)
	#--> 11
}

pf()
# Executed in 0.05 second(s)
