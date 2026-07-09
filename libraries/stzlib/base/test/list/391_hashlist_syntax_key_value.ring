# Narrative
# --------
# Shows how Softanza recognizes a Ring hashlist literal via IsHashList().
# In Ring the [ :key = value, ... ] form builds a genuine hashlist (a list
# of [key, value] pairs), so IsHashList() returns true for it and for the
# equivalent explicit [ ["name","Mansour"], ["age",45] ] form. The trap is
# the quoted [ "name" = "Mansour", ... ] form: here = is the equality
# operator, not a key binding, so each entry collapses to a boolean test.
# Since "name" != "Mansour" and "age" != 45, IsHashList() returns false and
# @@() reveals the list actually holds [ 0, 0 ] -- two failed comparisons.
#
# Extracted from stzlisttest.ring, block #391 (Scenario form).

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("IsHashList recognizes :key = value literals but not string = comparisons")
	Then("the :key = value form is a genuine hashlist",
		IsHashList([ :name = "Mansour", :age = 45 ]), TRUE)
	Then("...equivalent to the explicit list-of-pairs form",
		IsHashList([ [ "name", "Mansour"], [ "age", 45] ]), TRUE)
	Then("the quoted 'string' = value form is NOT a hashlist ( = is equality )",
		IsHashList([ "name" = "Mansour", "age" = 45 ]), FALSE)
	Then("...it actually collapses to two failed comparisons [ 0, 0 ]",
		@@( [ "name" = "Mansour", "age" = 45 ] ), @@([ 0, 0 ]))
EndScenario()

Summary()
