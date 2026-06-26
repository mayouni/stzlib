# Narrative
# --------
# Section(n1, n2) vs out-of-range bounds.
#
# Block #46's narration documents Section() as the CONSERVATIVE form that should
# RAISE ("Indexes out of range!") when the bounds escape the string, leaving the
# lenient SectionXT() to handle negatives/overshoot quietly.
#
# SEMANTICS TO CONFIRM (deferred -- see _AUDIT_DEFECTS.md): the current impl does
# NOT raise -- Q("SOFTANZA").Section(-99, 99) returns the whole "SOFTANZA"
# (silently clamped). Either Section() should enforce its conservative contract
# and raise, or block #46's narration is wrong. Pending the author's call; left
# in print form, NOT asserted.

load "../../stzBase.ring"

pr()

? @@( Q("SOFTANZA").Section(-99, 99) )
#--> currently "SOFTANZA" (block #46 says it should raise "Indexes out of range!")

pf()
