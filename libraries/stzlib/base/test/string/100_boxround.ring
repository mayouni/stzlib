# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #100.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Box-rendering cluster"):
# BoxRound() renders with ASCII instead of the rounded Unicode glyphs (╭╮╰╯),
# and BoxRoundChars() emits garbled ruler/marker rows ("m   ,   ...   n" /
# "p   4   ...   o") around the chars instead of a clean per-char boxed row.
# Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

? BoxRound("SOFTANZA")

? BoxRound(
	BoxRoundChars("SOFTANZA") + NL +
	BoxRound(Spacify("IS GREAT!")) + NL +
	"ACTUALLY, IT'S..." + NL +
	Box("AWOSME!")
)

pf()
