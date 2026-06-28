# Narrative
# --------
# String editing via the (-) operator on a Q()/stzString (NON-mutating).
#
# `- N` trims N trailing chars; `- "x"` removes every "x". Q-elevation applies:
# a RAW operand (- 3, - "*") yields the raw result string, so a bare `?` prints
# it; a Q()-WRAPPED operand (- Q("*")) yields a chainable stzString, so you read
# it with a projection like .StzType() / .Lowercased(). (See 996_minusoperator
# for the raw form on a plain stzString.)
#
# Repositioned from test/list (stzlisttest.ring, block #421): this is a
# stzString test, so it belongs under test/string.

load "../../stzBase.ring"

pr()

? Q("A**BC***DE***") - 3	# Remove the last 3 chars
#--> A**BC***DE

? Q("A**BC***DE***") - "*"
#--> ABCDE

? ( Q("A**BC***DE***") - Q("*") ).StzType() + NL
#--> stzstring

? ( Q("A**BC***DE***") - Q("*")  ).Lowercased()
#--> abcde

pf()
# Executed in 0.02 second(s).
