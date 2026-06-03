# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #881.
#ERR Error (R3) : Calling Function without definition: removext

load "../../stzBase.ring"

	

pr()

Q("__♥__♥__(♥__") {
	
	RemoveXT( "(", :BeforeLast = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()

pf()
# Executed in 0.05 second(s)
