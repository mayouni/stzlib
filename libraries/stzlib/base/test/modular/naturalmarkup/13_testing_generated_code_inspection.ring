# Narrative
# --------
# Testing generated code inspection
#
# Extracted from stznaturalmarkuptest.ring, block #13.

load "../../../stzBase.ring"


	cMarkup = '
	Create {+numbers:list ~1} with {#1 [1, 2, 3]}.
	{show-0it}
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()
	
	? "Generated Ring code:"
	? oNML.GeneratedCode()

#--> [1, 2, 3]
#--> Generated Ring code:
#--> onumbers = new stzList([1, 2, 3])
#--> onumbers.Show()

proff()
