load "../../stzBase.ring"
load "../_narrated.ring"

# FindW -- the positions of the characters satisfying a predicate (FindW returns
# POSITIONS; use CharsW for the characters themselves). Engine-backed, no
# eval(); accepts { } blocks and Q(@char).Method() sugar. Migrated from the
# retired FindWXT. Codepoint-aware -- works on multibyte characters.

Scenario("FindW locates a multibyte character by codepoint position")
	Given("a run of dots with two heart signs at codepoints 4 and 8")
	Then("FindW reports those two positions",
		@@( Q("...♥...♥...").FindW('@char = "♥"') ), @@([ 4, 8 ]))
EndScenario()

Summary()
