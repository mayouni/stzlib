# Narrative
# --------
# Treating a list's CODE STRING as text, then slicing it.
#
# ToCodeQ() renders the list to its Ring source form ("[ 1, 2, ..., 10 ]")
# and hands back a stzString, so the whole string toolkit becomes
# available. Here we find the 3rd and 7th commas and take the Section
# between them -- pulling "3, 4, 5, 6, 7" straight out of the rendered
# code. A small demo of how Softanza objects compose: a list view turning
# into a string view mid-chain.
#
# Extracted from stzlisttest.ring, block #181.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Treating a list's CODE STRING as text, then slicing it.")

	o1 = new stzList(1:10)
	oListInStr = o1.ToCodeQ()

	n1 = oListInStr.FindNth(3, ",")
	n2 = oListInStr.FindNth(7, ",")

	Then("section example 1", @@( oListInStr.Section(n1-1, n2-1) ), @@( "3, 4, 5, 6, 7" ))
EndScenario()

Summary()
