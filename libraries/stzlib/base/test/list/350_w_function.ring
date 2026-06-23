# Narrative
# --------
# Wraps a condition string with the W() conditional-code helper.
#
# W() is Softanza's lightweight builder for the engine-side
# conditional DSL: given a predicate expression like
# 'len(@item)=3', it returns the two-element pair
# [ "where", "len(@item)=3" ]. The leading "where" tag is what
# downstream filtering methods (Find, Select, Remove, ...) look
# for to recognise that the argument is a condition to evaluate
# per item (with @item bound to each element) rather than a
# literal value. Here pr()/pf() just frame the call so the raw
# shape of the produced pair is visible.
#
# Extracted from stzlisttest.ring, block #350.

load "../../stzBase.ring"

pr()

? W('len(@item)=3')
#--> [ "where", "len(@item)=3" ]

pf()
# Executed in almost 0 second(s).
