# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #412.
#
# NOTE (audit, 2026-07-02): DEFERRED. stzList.FindWXT is RETIRED by design
# (R14 "no definition") per the WXT disqualification -- W is the single
# conditional form. The replacement spelling is FindW(' @item = "." ')
# on the list. Same precedent as blocks #84 and #219-#221.

load "../../stzBase.ring"

pr()

o1 = new stzList([ ".", ".", "M", ".", "I", "X" ])
? o1.FindWXT(' @char = "." ')
#--> [1, 2, 4]

pf()
# Executed in 0.08 second(s) in Ring 1.21
# Executed in 0.17 second(s) in Ring 1.17
