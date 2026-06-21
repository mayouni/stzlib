# Narrative
# --------
# Type introspection on a Softanza string object.
#
# QQ() wraps a literal in a stzString; StzType() reports the object's own
# Softanza class identity -- "normal text" identifies as "stzstring". The two
# predicates that follow inspect the string's CONTENT rather than its class:
# IsNumberInString() and IsListInString() ask whether the text spells a number
# or a bracketed list; plain prose is neither, so both answer FALSE.
# (Recorded "stztext" was stale -> stzstring.)
#
# Repositioned from test/list (stzlisttest.ring, block #347): this is a
# stzString test, so it belongs under test/string.

load "../../stzBase.ring"

pr()

? QQ("normal text").StzType()
#--> stzstring

o1 = new stzString("normal text")

? o1.IsNumberInString()
#--> FALSE

? o1.IsListInString()
#--> FALSE

pf()
# Executed in 0.07 second(s)
