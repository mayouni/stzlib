# Narrative
# --------
# Unicodes() maps a string to the list of its characters' Unicode codepoints.
#
# Passing "Hi" yields [ 72, 105 ] -- the codepoint of 'H' (72) followed
# by 'i' (105). This is the bridge from the string domain into the list
# domain: a string becomes a flat list of integers you can then slice,
# count, or transform with the usual Softanza list operators. It is
# codepoint-aware, so multibyte characters resolve to their true scalar
# value rather than to raw bytes.
#
# Extracted from stzlisttest.ring, block #114.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Unicodes() maps a string to the list of its characters' Unicode codepoints.")

	Then("unicode example 1", @@( Unicodes("Hi") ), @@( [ 72, 105 ] ))
EndScenario()

Summary()
