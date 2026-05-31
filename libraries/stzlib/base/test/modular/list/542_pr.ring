# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #542.

load "../../../stzBase.ring"


StzListQ([ "a", 1, "b", 2, "c", 3 ]) {

	ReplaceWXT( :Where = '{ isNumber(@item) }', :By = "*" )
	? @@( Content() )
	#--> [ "a", "*", "b", "*", "c", "*" ]
}

pf()
# Executed in 0.13 second(s).
