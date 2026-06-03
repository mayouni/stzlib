# Narrative
# --------
# Section(n1, n2) is the conservative form: when the bounds
# escape the string's natural index range it RAISES rather than
# silently clamping. The lenient SectionXT() (covered elsewhere)
# is the one that handles negatives and overshoot quietly.
#
# Extracted from stzStringTest.ring, the late conservative-Section
# block.

load "../../../stzBase.ring"


? @@( Q("SOFTANZA").Section(-99, 99) )
#--> Indexes out of range! n1 and n2 must be inside the string.
