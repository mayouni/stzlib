# Narrative
# --------
# SmartSplit test - preserving lists and strings
#
# Extracted from stznaturalmarkuptest.ring, block #14.
#ERR Error (R14) : Calling Method without definition: smartsplit

load "../../stzBase.ring"

pr()

	cMarkup = 'create {+list ~1} with {#1 ["one", "two"]} and "hello" then show'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oStr = new stzString(cMarkup)
	
	? "SmartSplit result:"
	? oNML.SmartSplit(oStr)

#--> ["create", "{+list", "~1}", "with", "{#1", ["one", "two"], "}", "and", "hello", "then", "show"]

proff()

pf()
