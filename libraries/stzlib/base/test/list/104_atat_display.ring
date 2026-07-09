# Narrative
# --------
# Turning on the @@() string-form pretty-printer with pr() and watching
# how it renders scalars, lists, embedded quotes, and multibyte emoji.
#
# @@() arms the pretty-printing mode so that ? shows values in their
# canonical Softanza literal form. @@() converts any value into that
# quoted, bracketed representation: a bare string is wrapped in double
# quotes, a list keeps its [ ... ] shape, and items that themselves
# contain a double-quote are wrapped in single quotes (and vice versa)
# so the literal round-trips cleanly. Note isNumber() is plain Ring and
# prints its numeric 0/1 result (0 here, since a list is not a number),
# unaffected by pr(). Emoji like the sun face survive the round-trip
# intact -- the console may show a blank, but the codepoint is preserved.
#
# Extracted from stzlisttest.ring, block #104.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Turning on the @@() string-form pretty-printer with pr() and watching how it renders scala")

	Then("atat_display example 1", @@( isNumber([ "'" ]) ), @@( 0 ))

	Then("atat_display example 2", @@( "🌞" ), @@( "🌞" ))

	Then("atat_display example 3", @@( [ 1, 2 ] ), @@( [ 1, 2 ] ))

	Then("atat_display example 4", @@( [ '"' ] ), @@( [ '"' ] ))

	Then("atat_display example 5", @@( [ "'" ] ), @@( [ "'" ] ))

	Then("atat_display example 6", @@( [ "1", "🌞", "ring" ] ), @@( [ "1", "🌞", "ring" ] ))
EndScenario()

Summary()
