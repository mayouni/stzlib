# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #880.

load "../../stzBase.ring"

	

pr()

Q("__(♥__♥__♥__") {

	RemoveXT( "(", :BeforeFirst = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()

pf()
# Executed in 0.05 second(s)
