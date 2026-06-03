# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #381.

load "../../stzBase.ring"


Q("__♥)__♥)__♥)__") {

	AddXT( "(", :BeforeEach = "♥" ) # ... you can also say :Before = "♥"
	? Content()
	#--> __(♥)__(♥)__(♥)__
}

StopProfiler()
# Executed in 0.06 second(s) in Ring 1.22
