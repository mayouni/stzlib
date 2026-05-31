# Narrative
# --------
# #INTERNAL #TODO Write a document about it
#
# Extracted from stzlisttest.ring, block #303.

load "../../../stzBase.ring"


pr()

# This function is used internally by Softanza in the stzList class

#                        3         5
? @FindNext([ "_", "_", "•", "_", "•", "_", "_" ], "•", :StartingAt = 3)
#--> 5

? @FindNext([ "_", "_", ["•"], "_", ["•"], "_", "_" ], "•", 3)
#--> 0

? @FindNext([ "_", "_", ["•"], "_", ["•"], "_", "_" ], ["•"], 3)
#--> -1

# The last one returns -1 because Ring can't find lists.
# to do so, you need to use stzList like this:

o1 = new stzList([ "_", "_", ["•"], "_", ["•"], "_", "_" ])
? o1.FindNext(["•"], :StartingAt = 3)
#--> 5

pf()
# Executed in 0.02 second(s) in Ring 1.22
