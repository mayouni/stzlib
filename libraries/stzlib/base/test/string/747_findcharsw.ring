load "../../stzBase.ring"
load "../_narrated.ring"

# FindCharsW -- positions matching a predicate. Engine-backed, no eval().
# Migrated from the retired FindCharsWXT; the StzCharQ(@Char).Lowercased() = "a"
# sugar (not in the engine DSL) is rewritten to the equivalent case-insensitive
# DSL predicate.

Scenario("FindCharsW locates a letter case-insensitively")
	Given('the string "SoftAnza Libraray"')
	Then('FindCharsW for "a" case-insensitively reports a and A positions',
		@@( Q("SoftAnza Libraray").FindCharsW('(@char = "a") or (@char = "A")') ),
		@@([ 5, 8, 14, 16 ]))
EndScenario()

Summary()
