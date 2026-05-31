# Narrative
# --------
# #narration
#
# Extracted from stzhashlisttest.ring, block #18.

load "../../../stzBase.ring"

pr()

# While working with stzHashLists, there may be a special need where you
# want to find a given item inside values that are of type list.

# Let's understand it by example:

	o1 = new stzHashList([
		:Positive	= [ :happy, :nice, :glad, :beautiful, :wanderful ],
		:Neutral  	= [ :is, :will, :can, :some ],
		:Negative	= [ :no, :not, :must, :difficult, :problem ]
	])

# If you need to find the value :nice, you won't be able to get it using:
	? @@(o1.FindValue(:nice)) + NL	#--> [ ]


# That's because there is no sutch value equal to the string :nice in all
# the three pairs of the hashlist.

# In fact, these values are all of type list. So if you want to find one of them
# you should provide it as a hole list, like that:

	? @@( o1.FindValue([ :is, :will, :can, :some ]) ) + NL	#--> [ 2 ]

# Now, because finding directly an item (which is an item of a value of type list)
# is something that you will need in practice, in many data-driven applications,
# Softanza proposes the FindItem() function to do just that!

# Hence, you can find :nice directly by saying:

	? @@( o1.FindItem(:nice) ) + NL
	#--> [ 1, [ 2 ] ]	# exists in pair 1 at position 2

	# if there was two :nice strings in the first pair, then
	# the result will be [ 1, [ 2, 4 ] ] for example.

# And you can find many items at once:

	? @@( o1.FindTheseItems([ :nice, :will, :must ]) ) + NL
	#--> [ [ 1, 2 ], [ 2, 2 ], [ 3, 3 ] ]

# And find all the existing items:

	? @@( o1.FindItems() ) + NL
	#--> [
	# 	[ 1, 1 ], [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 1, 5 ],
	# 	[ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 2, 4 ],
	# 	[ 3, 1 ], [ 3, 2 ], [ 3, 3 ], [ 3, 4 ], [ 3, 5 ]
	# ]

# You can return the items and their positions in the same time:

	? @@( o1.TheseItemsZ([ :glad, :can ]) )
	#--> [
	# 	[ "glad", [ [ 1, [ 3 ] ] ] ],
	# 	[ "can", [ [ 2, [ 3 ] ] ] ]
	# ]

pf()
# Executed in 0.09 second(s) in Ring 1.22
