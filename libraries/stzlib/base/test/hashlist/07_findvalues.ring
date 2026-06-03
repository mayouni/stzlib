# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #7.

load "../../stzBase.ring"

pr()

o1 = new stzHashList([
	:one   = [ "here" ],
	:two   = [ "and" ],
	:three = "not",
	:four  = [ "there" ]
])

# Finding some values (you are not going to find them ;)

? @@( o1.FindValues([ "here", "and", "there" ]) )
#--> [ ]

# There are no sutch values in the hashlist! In fact, they
# are hosted as items inside values of type list. So, if you
# need to find them, you can add the ..InLists() extension:

? @@( o1.FindTheseInLists([ "here", "and", "there" ]) )
#--> [ [ 1, 1 ], [ 2, 1 ], [ 4, 1 ] ]

# Or you can use the Item semantic like this:

? @@( o1.FindTheseItems([ "here", "and", "there" ]) )
#--> [ [ 1, 1 ], [ 2, 1 ], [ 4, 1 ] ]

# SEMANTIC NOTE: in the context of stzHashList, a VALUE is what
# you have side by side with the key. And you can find the VALUES
# using FindValues().
#
# When a VALUE is of type LIST, then you can find the ITEMS hosted
# inside those lists using FindInLists() or directly FindItems().
#
#WARNING: when you use FindValues, ITEMS inside lists are not found.
# And when you use FindInLists or FindItems then VALUES are not found.

pf()
# Executed in 0.04 second(s)
