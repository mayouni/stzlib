# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #101.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Box-rendering cluster"): Box() /
# BoxRound() render with ASCII (+, -, |) instead of the Unicode box-drawing
# glyphs the archive shows (┌─┐ / ╭─╮), so nested boxes don't line up and the
# round variant is not distinct from the square one. Left in print form; NOT
# asserted (box output is non-ASCII / fragile to assert).

load "../../stzBase.ring"

pr()

? Box("SOFTANZA") + NL
? Box(Box("SOFTANZA")) + NL
? BoxRound(BoxRound(Box("SOFTANZA")))

pf()
