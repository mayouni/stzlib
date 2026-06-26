# Narrative
# --------
# cName = "Gary"
#
# Extracted from stzStringTest.ring, block #111.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): $("... {var} ...") / Interpolate()
# does not substitute the placeholder -- it returns the template verbatim
# ("... {cName}!") instead of "... Gary!". (Same interpolation gap as block #54.)
# Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

cName = "Gary"

? $("It's been a real pleasure meeting you, {cName}!") # Or Interpolate()
#--> expected "...meeting you, Gary!" (currently leaves "{cName}" verbatim)

pf()
