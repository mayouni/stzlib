# Narrative
# --------
# StringifyAndReplace() stringifies every element of a list and then
# substitutes one substring for another across all of them in place.
#
# Here a stzList holds a mix of strings, a nested sublist, and a number.
# StringifyAndReplace("_", "heart") first coerces each item to its string
# form (the inner list becomes a quoted bracketed literal, the bare 9
# becomes "9"), then replaces every "_" with the heart glyph. Content()
# returns the mutated list, and @@() renders it: note the nested list is
# now a single string element, demonstrating that stringification flattens
# structure into text while preserving order.
#
# Extracted from stzlisttest.ring, block #92.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "--_--", [ 12, "--_--", 10], "--_--", 9 ])
o1.StringifyAndReplace("_", "♥")
? @@( o1.Content() )
#--> [ "--♥--", '[ 12, "--♥--", 10 ]', "--♥--", "9" ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.03 second(s) in Ring 1.19
