load "stzlib.ring"

/*---- #narration ContentSize() and MemorySize()
*/
pron()

# What is the size in bytes of the character "A"?
# You might think it's 1 byte, but:

? Size("A") # Same as SizeInBytes()
#--> 49

# It's 49 times larger than you might expect!

# In fact, the value returned by the function is actually
# the memory size of the character as allocated by Ring,
# not just the size of its content.

# Hence, we could write the same function as:

? MemSize("A") # Same as MemorySizeInBytes()
#--> 49

# and use another function to get the size of the content itself:

? ContentSize("A") # Same as ContentSizeInBytes()
#--> 1

# which is the same as the standard Ring function:

? len("A")
#--> 1


proff()
# Executed in 0 second(s).

/*---- #narration

pron()

# How many bytes are there in this japanese char (synonym of "Both" in english)?

? len("両")
#--> 3

# The char occupies 3 bytes in memory, which is true. But actually, Ring
# allocates some additional bytes to manage it internally...

? SizeInBytes("両")
#--> 51

# Let's ask Softanza to explain how we get these 51 bytes...
# ~> We just need to add and XT() prefix to the same function

? SizeInBytesXT("両")
#--> [
#	[ 'len("両")', 3 ],
#	[ 'RING_64BIT_STRING_STRUCTURE_SIZE', 48 ]
# ]

# As you see, we've got the initail 3 bytes, plus 48 bytes more, used
# by the internal structure for managing strings in Ring.

# Note that this value would be different, if the code is running on
# a computer with a 32bit architecture.

# In sutch case you will get:

? SizeInBytes("両")
#--> 43

# And:

? SizeInBytesXT("両")
#--> [
#	[ 'len("両")', 3 ],
#	[ 'RING_64BIT_STRING_STRUCTURE_SIZE', 40 ]
# ]

proff()
# Executed in 0.02 second(s).

/*----

pron()

? Q(20).SizeInBytes()
#--> 56

? Q("両").SizeInBytes()
#--> 51

? Q([ 20, "両" ]).SizeInBytes()
#--> 107

? Q([ "Ring", 20, "رينغ" ]).SizeInBytes()
#--> 164

? Q(new TempObject).SizeInBytes() # 7 more bytes taken by internal stzObject attributes
#--> 192

proff()

class TempObject
	Language = "Ring"
	Version = 20
	InArabic = "رينغ"

/*----

pron()

? SizeInBytes("Ring")
#--> 52

? SizeInBytes(20)
#--> 56

? SizeInBytes("رينغ")
#--> 56

? SizeInBytes([ "Ring", 20, "رينغ" ])
#--> 248

obj = new TempObject
? SizeInBytes(obj) 
#--> 248

proff()
# Executed in 0.02 second(s).

class TempObject
	Language = "Ring"
	Version = 20
	InArabic = "رينغ"

/*=========

pron()

?  5340.58 / 1024 + NL

? SizeInBytes(12)
#--> 56

? SizeInBytes([12])
#--> 136

? SizeInBytes(1:100)
#--> 5680

? SizeInBytes(1:1_000_000)
#--> 56_000_080

	? SizeInMegaBytes(1:1_000_000)
	#--> 54_687.58

	? SizeInGigaBytes(1:1_000_000) + NL
	#--> 53.41

proff()
# Executed in 0.14 second(s).
