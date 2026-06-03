# Narrative
# --------
# Cross-block context references
#
# Extracted from stznaturalmarkuptest.ring, block #9.
#ERR Error (R14) : Calling Method without definition: run

load "../../stzBase.ring"

pr()

	cMarkup = '
	I will create {+fruits:list ~1} with {#1 ["apple", "banana", "cherry"]}.
	
	Much later in my narrative...
	
	Remember {@fruits} from before? Let us {reverse} {@fruits} now.
	Show me the result: {show-0it}
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> ["cherry", "banana", "apple"]

proff()

pf()
