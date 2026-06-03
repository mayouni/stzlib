# Narrative
# --------
# Nested lists in literals
#
# Extracted from stznaturalmarkuptest.ring, block #17.

load "../../stzBase.ring"


	cMarkup = '
	Create {+matrix:list ~1} with {#1 [["a", "b"], ["c", "d"]]}.
	{show-0it}
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> [["a", "b"], ["c", "d"]]

proff()
