# Narrative
# --------
# The global @FindNext helper vs the stzList method -- and why finding a
# SUBLIST needs the object form.
#
# @FindNext is a fast, low-level global used internally by stzList. It
# works on scalars (finds "•" after position 3 -> 5), and when the items
# are sublists it can't match a scalar needle (-> 0) nor a list needle
# (-> -1, the engine's "lists not searchable here" signal). To search for
# a sublist item, go through a stzList object, whose FindNext compares by
# content (-> 5).
#
# Extracted from stzlisttest.ring, block #303.

load "../../stzBase.ring"

pr()

# This function is used internally by Softanza in the stzList class

#                        3         5
? @FindNext([ "_", "_", "•", "_", "•", "_", "_" ], "•", :StartingAt = 3)
#--> 5

? @FindNext([ "_", "_", ["•"], "_", ["•"], "_", "_" ], "•", 3)
#--> 0

? @FindNext([ "_", "_", ["•"], "_", ["•"], "_", "_" ], ["•"], 3)
#--> -1

# The last one returns -1 because the global helper can't search for lists.
# To do so, go through a stzList object like this:

o1 = new stzList([ "_", "_", ["•"], "_", ["•"], "_", "_" ])
? o1.FindNext(["•"], :StartingAt = 3)
#--> 5

pf()
# Executed in 0.02 second(s)
