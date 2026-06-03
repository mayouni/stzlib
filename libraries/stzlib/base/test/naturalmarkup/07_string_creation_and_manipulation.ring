# Narrative
# --------
# String creation and manipulation
#
# Extracted from stznaturalmarkuptest.ring, block #7.

load "../../stzBase.ring"


	cMarkup = '
	Let me work with {+greeting:string ~1} containing {#1 "  hello world  "}.
	First, {trim-0it} to clean up spaces.
	Then {capitalize} the {greeting:string}.
	Finally {show-0it}!
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> Hello World

proff()
