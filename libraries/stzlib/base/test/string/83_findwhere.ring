# Narrative
# --------
# #narration  (W conditional: FindWhere / ItemsWhere)
#
# Extracted from stzStringTest.ring, block #83.
#
# DEFERRED to the W/WXT-conditional pass (string step 2 -- see _AUDIT_DEFECTS.md
# and memory project_wxt_disqualification). The W mechanism itself works (e.g.
# SplitQ(" ").FindW(' len(@item) > 3 ') -> [1,3,5]), but the RICH condition used
# here -- Q(This[@i]).ContainsAnyOfThese( Q("vwto").Chars() ) -- evaluates to []
# under the current engine W-DSL (it does not support that method-call
# expression), so FindWhere/ItemsWhere return [] instead of [1,2,4,5] /
# [ "okay","one","two","three" ]. Needs a supported condition spelling or a DSL
# builtin. Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("okay one pepsi two three ")

cMyConditionIsVerified = '
	Q(This[@i]).ContainsAnyOfThese( Q("vwto").Chars() )
'

? o1.SplitQ(" ").FindWhere(cMyConditionIsVerified)  #--> expected [ 1, 2, 4, 5 ] (currently [ ])
? o1.SplitQ(" ").ItemsWhere(cMyConditionIsVerified) #--> expected [ "okay","one","two","three" ] (currently [ ])

pf()
