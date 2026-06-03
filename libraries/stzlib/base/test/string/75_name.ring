# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #75.

load "../../stzBase.ring"

pr()

StzNamedStringQ(:myname = "Mansour") {

	? Name()
	#--> :myname

	? Content()
	#--> "Mansour"

	? StzType()
	#--> :stznumber

}

pf()
#--> Executed in 0.04 second(s)
