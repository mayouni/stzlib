load "../../stzBase.ring"
load "../_narrated.ring"

# FindCharsW -- positions of the characters matching a predicate. Engine-backed,
# no eval(). Migrated from the retired FindCharsWXT.

Scenario("FindCharsW locates a specific letter")
	Given('the string "KALIDIA"')
	Then('FindCharsW reports the positions of "I"',
		@@( Q("KALIDIA").FindCharsW('@char = "I"') ), @@([ 4, 6 ]))
EndScenario()

Summary()
