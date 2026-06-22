# Narrative
# --------
# How the Q() shortcut object overloads the / operator to split a string,
# and how the resulting object is a chainable stzList.
#
# Q() is Softanza's universal wrapper. On a string, dividing by a number
# (Q("ABCABCABC") / 3) cuts the string into that many equal chunks, while
# dividing by a substring (Q("ABC-ABC-ABC") / "-") splits on that separator.
# Either way the / operator yields a stzlist (confirmed via .StzType()),
# so the split result keeps the full list vocabulary -- here .Lowercased()
# maps over every element to produce [ "abc", "abc", "abc" ]. The Q operand
# itself can also be wrapped (Q("-")), showing the operator accepts either
# a raw value or another Q object.
#
# Extracted from stzlisttest.ring, block #422.

load "../../stzBase.ring"

pr()

? Q("ABCABCABC") / 3	# Remove the last 3 chars
#--> [ "ABC", "ABC", "ABC" ]

? Q("ABC-ABC-ABC") / "-"
#--> [ "ABC", "ABC", "ABC" ]

? ( Q("ABC-ABC-ABC") / Q("-") ).StzType() + NL
#--> stzlist

? ( Q("ABC-ABC-ABC") / Q("-")  ).Lowercased()
#--> [ "abc", "abc", "abc" ]

pf()
# Executed in 0.04 second(s).
