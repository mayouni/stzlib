# Narrative
# --------
# Removing several items at once with the These() sentinel.
#
# Softanza overloads the "-" operator on stzList for removal. Passing a
# bare list could be ambiguous (one nested element vs. many items), so
# These([...]) marks the operand as "these individual items to remove."
# Here ["a","b","c"] - These(["b","a"]) drops both "b" and "a",
# regardless of order, leaving ["c"]. The result is read back with @@()
# in its bracketed string form.
#
# Extracted from stzlisttest.ring, block #458.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "c" ])
? @@( o1 - These([ "b", "a" ]))
#--> [ "c" ]

pf()
# Executed in almost 0 second(s).
