# Narrative
# --------
# Dividing a string with the `/` operator -- a Softanza idiom.
#
# Q(str) / n        -> split into n equal parts
# Q(str) / sep      -> split around the separator string
#
# The RETURN TYPE follows the divisor: a RAW divisor (a Ring number or
# string) gives back a plain list (handy to print directly), while a
# SOFTANZA-object divisor (Q("-")) gives back a chainable stzList object,
# so you can keep the fluent flow going -- .StzType(), .Lowercased(), etc.
#
# Extracted from stzlisttest.ring, block #422.

load "../../stzBase.ring"

pr()

? Q("ABCABCABC") / 3	# divide into 3 equal parts
#--> [ "ABC", "ABC", "ABC" ]

? Q("ABC-ABC-ABC") / "-"	# split around "-"
#--> [ "ABC", "ABC", "ABC" ]

# A Softanza-object divisor -> a chainable stzList object:
? ( Q("ABC-ABC-ABC") / Q("-") ).StzType() + NL
#--> stzlist

? ( Q("ABC-ABC-ABC") / Q("-")  ).Lowercased()
#--> [ "abc", "abc", "abc" ]

pf()
# Executed in 0.04 second(s).
