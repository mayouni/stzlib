# Narrative
# --------
# Demonstrates stzList.IsMadeOfUniformLists(): a list is "made of
# uniform lists" when every one of its items is itself a list and
# all those inner lists share the same length.
#
# Here the outer list holds three sublists -- letters, numbers, and
# a mix of NULL/empty-list -- each of length 3. Because the contents
# do not matter (only that each item is a 3-element list), the check
# returns TRUE. The method is the size-focused alias of
# IsMadeOfUnisizeLists(): "uniform" here means uniform in size, not
# in element type.
#
# Extracted from stzlisttest.ring, block #232.

load "../../stzBase.ring"

pr()

o1 = new stzList([
	[ "A", "B", "C" ],
	[ 1, 2, 3 ],
	[ NULL, NULL, [] ]
])

? o1.IsMadeOfUniformLists() # Or more precisely: IsMadeOfUnisizeLists()
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.27
