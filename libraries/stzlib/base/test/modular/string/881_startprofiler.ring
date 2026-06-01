# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #881.

load "../../../stzBase.ring"

	
Q("__♥__♥__(♥__") {
	
	RemoveXT( "(", :BeforeLast = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.05 second(s)
