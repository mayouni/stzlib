# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #383.

load "../../stzBase.ring"


Q("__♥)__♥__♥__") {

	AddXT( "(", :BeforeFirst = "♥" )
	? Content()
	#--> __(♥)__♥__♥__
}

StopProfiler()
# Executed in 0.04 second(s)
