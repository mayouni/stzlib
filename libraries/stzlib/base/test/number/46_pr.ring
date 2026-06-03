# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #46.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

decimals(3)
? 81.8
#--> 81.800

StzNumberQ("81.8") {

	? RoundedTo(3)
	#--> "81.8"

	? RoundedToXT(3)
	#--> "81.800"

}

pf()
# Executed in 0.05 second(s)
