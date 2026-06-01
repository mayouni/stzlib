# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #879.

load "../../../stzBase.ring"

	
Q("__♥__(♥__♥__") {
	
	RemoveXT( "(", :BeforeNth = [2, "♥"] )
	? Content()
	#--> __♥__♥__♥__

}
	
StopProfiler()
# Executed in 0.04 second(s)
