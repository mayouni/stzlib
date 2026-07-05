# Narrative
# --------
#
# NOTE (audit, 2026-07-05): DEFERRED -- Naturally() is the stzNatural
# natural-language-to-code translator, a separate subsystem; the block
# exercises its empty-value protection, not stzString. Goes to the
# stzNatural pass.
# EMPTY VALUE PROTECTION
#
# Extracted from stznaturaltest.ring, block #27.

load "../../stzBase.ring"


pr()

o1 = Naturally("
    Create a string with ''
    Uppercase it
    Show it
")
#--> ""

? o1.Code()
# oStr = StzStringQ("")
# ? oStr.Content()
'
oStr = StzStringQ("")
oStr.Uppercase()
? oStr.Content()
@result = oStr.Content()
'

pf()
