# Narrative
# --------
# pr()  (FindWXT -- retired)
#
# Extracted from stzStringTest.ring, block #84.
#
# DEFERRED to the W/WXT-conditional pass (string step 2). FindWXT has already
# been RETIRED (R14: "Calling Method without definition: findwxt") -- it was the
# stzList WXT form removed during the list WXT disqualification, and SplitQ(" ")
# returns a stzList. Its replacement is the W form (block #83's FindWhere/FindW).
# This block is therefore a near-duplicate of #83; kept in print form as a record
# of the retired call. NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("okay one pepsi two three ")
? o1.SplitQ(" ").FindWXT(' Q(@item).ContainsAnyOfThese( Q("vwto").Chars() ) ')
#--> [ 1, 2, 4, 5 ] (FindWXT retired; use FindW -- see block #83, also currently broken for this condition)

pf()
