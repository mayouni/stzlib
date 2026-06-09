# Narrative
# --------
#
# Extracted from stzchartest.ring, block #120.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

# The "A":"E" syntax is a beautiful feature of Ring:

? "A" : "E"	#--> [ "A", "B", "C", "D", "E" ]

# And it works backward also like this:

? "E" : "A"	#--> [ "E", "D", "C", "B", "A" ]

# Softanza reproduces it using UpTo() and DownTo() functions:

? StzCharQ("A").UpTo("E")	#--> [ "A", "B", "C", "D", "E" ]
? StzCharQ("E").DownTo("A")	#--> [ "E", "D", "C", "B", "A" ]

# And extends it to cover any Unicode char not only ASCII chars
# as it is the case for the Ring syntax:

? StzCharQ("ب").UpTo("ج") 	#--> [ "ب", "ة", "ت", "ث", "ج" ]
? StzCharQ("ج").DownTo("ب")	#--> [ "ج", "ث", "ت", "ة", "ب" ]

pf()
# Executed in 0.04 second(s) in Ring 1.23
