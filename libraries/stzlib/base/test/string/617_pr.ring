# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #617.

load "../../stzBase.ring"


CheckparamsOff() # Potential Gain of performance

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? FindNthPreviousMarquer(1, 50)
	#--> 44

	? @@( PreviousMarquerZ(50) )
	#--> [ "#3", 44 ]

}

pf()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.79 second(s) in Ring 1.18
