# Narrative
# --------
# #narration
#
# Extracted from stztabletest.ring, block #212.

load "../../../stzBase.ring"


pr()

# If the column of sort is uniform (made of same item),
# Softanza looks backward to the columns coming before.

# If a column with distinct items is found, the sort
# is made on it.

# Otherwise, it goes forward and checks the columns
# coming after and does the same thing.

# If a column with distinct items is found, the sort
# is made on it.

# Otherwise, all columns are made of same items, and
# no sort is performed.

? @@NL( SortListsOn( 3, [

	[ 1, 1, 1, 3, 1 ],
	[ 1, 1, 1, 7, 1 ],
	[ 1, 1, 1, 2, 1 ]

]) )
#--> [
#	[ 1, 1, 1, 2, 1 ],
#	[ 1, 1, 1, 3, 1 ],
#	[ 1, 1, 1, 7, 1 ]
# ]

pf()
# Executed in 0.04 second(s)
