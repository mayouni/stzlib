# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #381.
#ERR Error (R3) : Calling Function without definition: addxt

load "../../stzBase.ring"

pr()

Q("__♥)__♥)__♥)__") {

	AddXT( "(", :BeforeEach = "♥" ) # ... you can also say :Before = "♥"
	? Content()
	#--> __(♥)__(♥)__(♥)__
}

StopProfiler()

pf()
# Executed in 0.06 second(s) in Ring 1.22
