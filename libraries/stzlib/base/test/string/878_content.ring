# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #878.

load "../../stzBase.ring"

	

pr()

Q("__(♥__(♥__(♥__") {

	RemoveXT( "(", :BeforeEach = "♥" ) # ... you can also say :Before = "♥"
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()

pf()
# Executed in 0.04 second(s)
