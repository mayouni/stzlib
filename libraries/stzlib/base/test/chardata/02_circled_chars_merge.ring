# Narrative
# --------
# Demonstrates list merging between two Unicode-block lists --
# CircledDigitUnicodes() (codepoints 9312..) and CircledLatinLetterUnicodes()
# -- using the Q() / MergedWith() fluent chain, then displayed via
# ShowShort() for a compact head/tail preview.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? ShowShort(
	Q( CircledDigitUnicodes() ).
	MergedWith( CircledLatinLetterUnicodes() )
)
#--> [ 9312, 9313, 9314, "...", 9447, 9448, 9449 ]

pf()
# Reference timings:
# - ~0s   in Ring 1.26
# - 0.01s in Ring 1.23
