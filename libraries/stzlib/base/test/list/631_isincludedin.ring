# Narrative
# --------
# IsIncludedIn vs AreIncludedIn -- singular tests the list as ONE item inside
# the host (the whole [ "green", "red" ] is not itself an element of the host,
# so FALSE), while the plural tests that EACH item is present in the host
# (both "green" and "red" are, so TRUE). The singular/plural pair encodes the
# whole-vs-elementwise distinction in the method name itself.
#
# Extracted from stzlisttest.ring, block #631 (Scenario form).

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("IsIncludedIn (whole) vs AreIncludedIn (each item) subset tests")
	o1 = new stzList([ "green", "red" ])
	Then("IsIncludedIn: the list is not itself one element of the host",
		o1.IsIncludedIn([ "green", "red", "blue" ]), FALSE)
	Then("AreIncludedIn: every item is present in the host",
		o1.AreIncludedIn([ "green", "red", "blue" ]), TRUE)
EndScenario()

Summary()
