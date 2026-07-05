load "../../stzBase.ring"
load "../_narrated.ring"

# new_stz(:Class, value) builds a Softanza object whose type is chosen
# at runtime; Stz(:Class, :Methods/:Attributes) introspects a class
# without instantiating, and accepts a :Where filter.
# (The archive's "HI3" was a stray-3 garble; Uppercased() is "HI".)
# Extracted from stzGlobalTest.ring, block #38.

Scenario("Metaprogramming helpers")
	o1 = new_stz(:String, "hi")
	Then("the runtime-typed string uppercases", o1.Uppercased(), "HI")
	o2 = new_stz(:List, 1:3)
	Then("the runtime-typed list counts", o2.NumberOfItems(), 3)
	Then("class attributes without an instance",
		ring_find( Stz(:String, :Attributes), "@pengine" ) > 0, TRUE)
	aFiltered = Stz(:Char, [ :Methods, :Where = 'Q(@Method).StartsWith("is")' ])
	Then("the method filter is non-empty", len(aFiltered) > 0, TRUE)
	bAllIs = TRUE
	nLen = len(aFiltered)
	for i = 1 to nLen
		if NOT (lower(left(aFiltered[i], 2)) = "is") bAllIs = FALSE ok
	next
	Then("... and every hit starts with is", bAllIs, TRUE)
EndScenario()

Summary()
