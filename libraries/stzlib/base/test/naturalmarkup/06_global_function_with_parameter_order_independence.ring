# Narrative
# --------
# Global function with parameter order independence
#
# Extracted from stznaturalmarkuptest.ring, block #6.

load "../../stzBase.ring"

pr()

cMarkup = `
Let me {^joinXT ~2} using {#2 " | "} as separator with {#1 ["alpha", "beta", "gamma"]}.
What type is that? {?type}
{show} it
`

oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> STRING
#--> alpha | beta | gamma

pf()
