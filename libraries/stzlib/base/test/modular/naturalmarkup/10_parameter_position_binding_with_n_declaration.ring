# Narrative
# --------
# Parameter position binding with ~N declaration
#
# Extracted from stznaturalmarkuptest.ring, block #10.

load "../../../stzBase.ring"


	cMarkup = '
	I want to {^replace ~3} in text where {#2 "old"} becomes {#3 "new"} using {#1 "This is old text"}.
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> This is new text

proff()
