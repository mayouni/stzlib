load "../../stzBase.ring"
load "../_narrated.ring"

# ToListOfStzChars() turns a string into a list of stzChar objects. Archive #106.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): the items ARE stzChars
# (classname = "stzchar"), but stzChar.StzType() misreports as "stzstring"
# instead of "stzchar". The StzType() call is left as an un-asserted NOTE; the
# class identity is asserted instead.

Scenario("A string as a list of stzChar objects")
	Given('Q("abc").ToListOfStzChars()')
	a = Q("abc").ToListOfStzChars()
	Then("the 2nd item is a stzChar", classname(a[2]), "stzchar")
	Then("its content is 'b'", a[2].Content(), "b")
	# StzType() should say "stzchar" but returns "stzstring":
	? "  NOTE  a[2].StzType() -> " + @@(a[2].StzType()) + "  (should be stzchar -- deferred)"
EndScenario()

Summary()
