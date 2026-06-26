# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #99.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Box-rendering cluster"): Boxed() /
# BoxedRound() / EachCharBoxed() / EachCharBoxRounded() render with ASCII
# (+, -, |) instead of the Unicode box-drawing glyphs (the archive shows ┌─┐ /
# ╭─╮ / ┬┴), and the round variants are not visually distinct from the square
# ones. Likely the box-glyph mojibake issue (see memory feedback_source_mojibake).
# Left in print form; NOT asserted (box output is non-ASCII / fragile to assert).

load "../../stzBase.ring"

pr()

Q("PROGRAMMING") {
   ? Boxed()
   ? BoxedRound()
   ? EachCharBoxed()
   ? EachCharBoxRounded()
}

pf()
