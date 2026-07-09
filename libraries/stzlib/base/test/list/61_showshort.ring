# Narrative
# --------
# More L() ranges: native ":" vs L() across reals, negatives, and Unicode.
# Contrasts Ring's ":" (1:3 -> integers; 2.8:3.2 -> just the integer endpoints)
# with L(), which steps through real numbers at the endpoints' decimal
# granularity (2.8:3.2 -> 2.80,2.90,3,3.10,3.20), handles negative real ranges
# (-3.25:-3.20), and numbered / Unicode tokens ("v1":"v3", "♥1":"♥5", "A":"E").
#
# Extracted from stzlisttest.ring, block #61 (Scenario form). The two Arabic
# "#o-->" cases were observed terminal renderings (console display only), so
# they are left out of the deterministic assertions here.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Native ':' ranges vs L() over reals, negatives and Unicode tokens")
	Then("native 1:3 is the integer range",
		@@( 1 : 3 ), @@([ 1, 2, 3 ]))
	Then("native 2.8:3.2 keeps only the integer endpoints",
		@@( 2.8 : 3.2 ), @@([ 2, 3 ]))
	Then("L('2.8 : 3.2') steps at decimal granularity",
		@@( L('2.8 : 3.2') ), @@([ 2.80, 2.90, 3, 3.10, 3.20 ]))
	Then("L('0.07 : 0.10') steps in hundredths",
		@@( L('0.07 : 0.10') ), @@([ 0.07, 0.08, 0.09, 0.10 ]))
	Then("L(' -3.25 : -3.2 ') handles a negative real range",
		@@( L(' -3.25 : -3.2 ') ), @@([ -3.25, -3.24, -3.23, -3.22, -3.21, -3.20 ]))
	Then("L() over v1..v3 steps numbered tokens",
		@@( L(' "v1" : "v3" ') ), @@([ "v1", "v2", "v3" ]))
	Then("L() over heart-prefixed 1..5 steps Unicode tokens",
		@@( L(' "♥1" : "♥5" ') ), @@([ "♥1", "♥2", "♥3", "♥4", "♥5" ]))
	Then("L() over A..E steps letters",
		@@( L(' "A" : "E" ') ), @@([ "A", "B", "C", "D", "E" ]))
EndScenario()

Summary()
