# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #615.

load "../../stzBase.ring"

pr()

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? PreviousMarquers(:StartingAt = 50 )
	#--> [ "#1", "#2", "#3" ]

	? NextMarquers(:StartingAt = 15)
	#--> [ "#2", "#3", "#1" ]

}

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.66 second(s) in Ring 1.18
