# Narrative
# --------
# Method chaining with dot notation
#
# Extracted from stznaturalmarkuptest.ring, block #8.

load "../../stzBase.ring"


	cMarkup = '
	Create {+data:list ~1} with {#1 ["first", "second", "third"]}.
	Get the {data:list..content..count}.
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> 3

proff()
