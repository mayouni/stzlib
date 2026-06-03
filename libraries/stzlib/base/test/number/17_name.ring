# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #17.

load "../../stzBase.ring"

pr()

StzNamedNumberQ(:myage = 47) {

	? Name()
	#--> :myage

	? Content()
	#--> 47

	? StzType()
	#--> :stznumber

}

pf()
# Executed in 0.03 second(s)
