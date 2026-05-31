# Narrative
# --------
# SmartSplit test - preserving lists and strings
#
# Extracted from stznaturalmarkuptest.ring, block #14.

load "../../../stzBase.ring"


	cMarkup = 'create {+list ~1} with {#1 ["one", "two"]} and "hello" then show'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oStr = new stzString(cMarkup)
	
	? "SmartSplit result:"
	? oNML.SmartSplit(oStr)

#--> ["create", "{+list", "~1}", "with", "{#1", ["one", "two"], "}", "and", "hello", "then", "show"]

proff()
