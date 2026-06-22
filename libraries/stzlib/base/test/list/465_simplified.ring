# Narrative
# --------
# Shows Simplified() collapsing internal whitespace runs to single spaces.
#
# Softanza's Simplified() trims leading/trailing blanks and squeezes every
# run of inner whitespace down to one space. The first call applies it to a
# plain string, leaving "ab [] cd". The second feeds the textual rendering of
# a nested list (via list2code) through StzString, so the deeply nested
# literal [ "a", [ [ ] ], "b" ] is normalised to evenly single-spaced form.
# This is the idiomatic way to canonicalise messy or code-generated text.
#
# Extracted from stzlisttest.ring, block #465.

load "../../stzBase.ring"

pr()

? StzStringQ("ab []    cd").Simplified()
#--> ab [] cd

? Q(list2code([ "a", [ [] ], "b" ])).Simplified()
#--> [ "a", [ [ ] ], "b" ]

pf()
# Executed in 0.01 second(s).
