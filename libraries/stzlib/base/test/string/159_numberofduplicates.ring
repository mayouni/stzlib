# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #159.
#
# DEFECT / SEMANTICS (deferred -- see _AUDIT_DEFECTS.md, block 129 cluster):
# Duplicates() returns duplicated CHARACTERS [ "p", " ", "r", "i", "n", "g" ]
# (NumberOfDuplicates 6), but this archive expected duplicated SUBSTRINGS incl
# "ri","rin","ring" (count 12). The impl is consistent (block 157's char result
# matched its archive), so the substring expectation here is the divergent one --
# but the intended Duplicates() contract is still open. Left in print form; NOT
# asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("ring php ringoria")
? o1.NumberOfDuplicates()  #--> archive 12 (currently 6 -- dup chars)
? @@( o1.Duplicates() )    #--> archive [ "r","ri","rin","ring","i","in","ing","n","ng","g"," ","p" ]
                           #    (currently [ "p"," ","r","i","n","g" ])

pf()
