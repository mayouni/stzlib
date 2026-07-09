# Narrative
# --------
# AllItemsExcept(item) returns every element of the list except the given
# one, leaving the source untouched -- a passive "everything but this" query.
#
# Extracted from stzlisttest.ring, block #537 (Scenario form).

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("AllItemsExcept returns every item except the given one")
	o1 = new stzList([ "a", "b", 3, "c"])
	Then("AllItemsExcept(3) drops the 3 and keeps the rest",
		@@( o1.AllItemsExcept(3) ), @@([ "a", "b", "c" ]))
EndScenario()

Summary()
