# Narrative
# --------
# Global function with parameter order independence
#
# Extracted from stznaturalmarkuptest.ring, block #5.

load "../../../stzBase.ring"

pr()

cMarkup = `
{^joinXT ~2} the strings in {#1 ["alpha", "beta", "gamma"]} using {#2 " | "}
What type is that? {?type}
{show} it
`

oNML = new stzNaturalMarkup(cMarkup)
oNML.Run()

pf()
