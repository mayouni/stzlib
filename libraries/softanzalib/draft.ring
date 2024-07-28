load "stzprofsys.ring"

pron()

# In Ring, the content size of a number is always 3 bytes.
# This is because a number is internally represented as a C DOUBLE.

? CSize(7) # Or ContentSize()
#--> 3

# There is no memory overhead for storing numbers in Ring.
# Therefore, the memory size of a number is equal to its content size:

? MSize(7) # Or MemorySize()
#--> 3

# This changes when we store numbers in a list.

# While the list's content size is the sum of its
# items' content sizes:

? CSize([1, 2, 3]) + NL
#--> 9

# the actual memory size of the list is different:

? MSize([1, 2, 3]) + NL
#--> 257

# The difference is significant, more than 28 times in this case!
# This warrants an explanation, and the XT() prefix helps with that:

? MSizeXT([1, 2, 3])
#--> [
#	[ "RING_64BIT_LIST_STRUCTURE_SIZE", 80 ],
#	[ "RING_64BIT_ITEM_STRUCTURE_SIZE * 3", 72 ],
#	[ "RING_64BIT_ITEMS_STRUCTURE_SIZE * 3", 96 ],
#	[ "RING_64BIT_ITEMS_CONTENT_SIZE",  9 ]
# ]

# As you can see, if your code is running, like me, on a 64-bit
# architecture, there is space allocated for the internal list
# structure itself (80 bytes), an overhead of 72 + 96 bytes
# required by the internal item structures, and, of course,
# the 9 bytes needed to store the 3 numbers as double numbers
# (3 bytes each).

# The total gives you the result from MSize(), which is 257 bytes.

? NL + "---" + NL

#NOTE
# We can check the values for 32-bit architectures, even if we are
# in 64-bit architecture, by adding a 32() prefix:

? MSize32([ 1, 2, 3 ]) + NL
#--> 153

# and

? MSize32XT([ 1, 2, 3 ])
#--> [
#	[ "RING_32BIT_LIST_STRUCTURE_SIZE", 48 ],
#	[ "RING_32BIT_ITEM_STRUCTURE_SIZE * 3", 48 ],
#	[ "RING_32BIT_ITEMS_STRUCTURE_SIZE * 3", 48 ],
#	[ "RING_32BIT_ITEMS_CONTENT_SIZE",  9 ]
# ]

# The same can be done by adding a 64() prefix, allowing you to
# perform memory size simulations for any platform, regardless of
# the architecture your code is running on ;)

proff()
# Executed in 0.02 second(s).


