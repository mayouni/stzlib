# Narrative
# --------
# Multiple parameters in any order
#
# Extracted from stznaturalmarkuptest.ring, block #16.

load "../../stzBase.ring"


	cMarkup = '
	Process data with {^compute ~3} where {#3 "fast"} mode is set, using {#1 [10, 20, 30]} and {#2 "sum"} operation.
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> [computed result based on parameters]

proff()
