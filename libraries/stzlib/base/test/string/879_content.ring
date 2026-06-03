# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #879.
#ERR Error (R3) : Calling Function without definition: removext

load "../../stzBase.ring"

	

pr()

Q("__♥__(♥__♥__") {
	
	RemoveXT( "(", :BeforeNth = [2, "♥"] )
	? Content()
	#--> __♥__♥__♥__

}
	
StopProfiler()

pf()
# Executed in 0.04 second(s)
