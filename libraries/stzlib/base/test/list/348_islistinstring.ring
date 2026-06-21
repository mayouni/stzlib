# Narrative
# --------
# Probes how Softanza inspects a string's textual content: the
# IsListInString() predicate and the StzType() content classifier.
#
# IsListInString() asks whether a string literally spells out a list;
# the pair-shaped " "A" : "C" " is not bracketed list syntax, so it
# answers FALSE. StzType() then sniffs the kind of value a string
# encodes: a single letter and free-form prose both register as the
# generic stzstring, a bare digit run reads as stznumber, and a
# bracketed "[ 1, 2, 3 ]" is recognized as stzlist. The takeaway is
# that StzType() classifies the represented value, defaulting to
# stzstring whenever the text is neither numeric nor list-shaped.
#
# Extracted from stzlisttest.ring, block #348.

load "../../stzBase.ring"

pr()

? Q(' "A" : "C" ').IsListInString()
#--> FALSE

? QQ("C").StzType()
#--> stzstring

? QQ("12500").StzType()
#--> stznumber

? QQ("[ 1, 2, 3 ]").StzType()
#--> stzlist

? QQ("normal text").StzType()
#--> stzstring

pf()
# Executed in 0.14 second(s) in Ring 1.22
