# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #878.

load "../../../stzBase.ring"

	
Q("__(♥__(♥__(♥__") {

	RemoveXT( "(", :BeforeEach = "♥" ) # ... you can also say :Before = "♥"
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.04 second(s)
