# Narrative
# --------
# The minus operator on a stzString removes every occurrence of a
# substring, returning a fresh value without mutating the receiver.
#
# Here `o1 - "*"` strips all asterisks from "A**BC***DE***", yielding
# "ABCDE". The follow-up `o1.Content()` confirms the Softanza idiom of
# value-semantics for operator expressions: the operation produces a
# new result while the original object is left untouched, still holding
# "A**BC***DE***". The pr()/pf() pair wraps the block in the profiler,
# whose terminal "STOPPED!" banner marks a successful pass.
#
#
# Repositioned from test/list (this is a stzString test, so it belongs under test/string).
# Extracted from stzlisttest.ring, block #420.

load "../../stzBase.ring"

pr()

o1 = new stzString("A**BC***DE***")
? o1 - "*"
#--> ABCDE

# Note that o1 content did not change:

? o1.Content()
#--> A**BC***DE***

pf()
# Executed in 0.01 second(s).
