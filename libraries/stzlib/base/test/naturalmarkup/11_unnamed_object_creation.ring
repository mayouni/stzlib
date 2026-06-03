# Narrative
# --------
# Unnamed object creation
#
# Extracted from stznaturalmarkuptest.ring, block #11.

load "../../stzBase.ring"

pr()

	cMarkup = '
	Create an {+list} with default empty content.
	{fill-it-with ~1} these values: {#1 ["a", "b", "c"]}.
	{show-0it}
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> ["a", "b", "c"]

proff()

pf()
