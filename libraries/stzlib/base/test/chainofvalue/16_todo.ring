# Narrative
# --------
# TODO
#
# Extracted from stzchainofvaluetest.ring, block #16.

load "../../stzBase.ring"


BeforeDoingThis('{ ? 24 / v }').CheckThat('{ v != 0 }')
DoThis('{ ? "Hi!" + NL }')._(10).Times
DoThis('{ v++ ? v }').While('{ v < 9 }')
Until('{ v = "12000" '}).DoThis('{ v += "0" ? v }')
