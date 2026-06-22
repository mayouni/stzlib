# Narrative
# --------
# Removing a set of named items from a stzList using the These() filter.
#
# These([...]) packages a list of values as a removal selector, so the
# minus operator on a stzList becomes a set-difference: every item whose
# value matches an entry in These(...) is dropped. Here "bo" and "wo"
# are pulled out of [ "fa", "bo", "wy", "wo" ], leaving [ "fa", "wy" ]
# in their original relative order. This is the value-based counterpart
# to position-based removal, reading as plain English: take the list,
# minus these.
#
# Extracted from stzlisttest.ring, block #433.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "fa", "bo" , "wy" , "wo" ])
? @@( o1 - These([ "bo", "wo" ]) )
#--> [ "fa", "wy" ]

pf()
# Executed in almost 0 second(s).
