# Narrative
# --------
# Full Palette Count
#
# Extracted from stzdiagramcolortest.ring, block #10.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

aPalette = BuildColorPalette()
? len(aPalette)
#--> 130
# 125 until 2026-08-22, when :Muted was added: the fifth semantic value
# plus its four intensity variations, registered as real palette entries
# so every path that works for a colour works for it.

pf()
# Executed in 0.02 second(s) in Ring 1.25
