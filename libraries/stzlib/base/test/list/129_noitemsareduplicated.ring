# Narrative
# --------
# NoItemsAreDuplicated(): the positive, readable spelling of "this list
# is a set" -- every item appears exactly once.
#
# It is the logical complement of ContainsDuplicates(), and an alias of
# ContainsNoDuplicates(). Note how items of mixed type coexist: the
# range 1:3 expands to 1,2,3 and none collides with the strings "2" or
# "C", because Softanza compares items by a stringified, type-aware key
# rather than Ring's coercing `=`.
#
# Extracted from stzlisttest.ring, block #129.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("NoItemsAreDuplicated(): the positive, readable spelling of this list is a set -- every ite")

		o1 = new stzList([ "A", "B", "2", 1:3, "C", 2 ])
	Then("noitemsareduplicated example 1", @@( o1.NoItemsAreDuplicated() ), @@( TRUE ))

		o1 = new stzList("A":"E")
	Then("noitemsareduplicated example 2", @@( o1.NoItemsAreDuplicated() ), @@( TRUE ))
EndScenario()

Summary()
