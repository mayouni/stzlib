# Narrative
# --------
# #narration GENERALISATION OF _:_ RING SYNTAX
#
# Extracted from stzStringTest.ring, block #635.

load "../../../stzBase.ring"


pr()

# The "A":"E" syntax is a beautiful feature of Ring:

? "A" : "E"
#--> [ "A", "B", "C", "D", "E" ]

# And it works backward like this:

? "E" : "A"
#--> [ "E", "D", "C", "B", "A" ]

# Softanza reproduces it using UpTo() and DownTo() functions:

? Q("A").UpTo("E")
#--> [ "A", "B", "C", "D", "E" ]

? Q("E").DownTo("A")
#--> [ "E", "D", "C", "B", "A" ]

# And extends it to cover any Unicode char not only ASCII chars
# as it is the case for the Ring syntax:

? Q("ب").UpTo("ج") 	#--> [ "ب", "ة", "ت", "ث", "ج" ]
? Q("ج").DownTo("ب")	#--> [ "ج", "ث", "ت", "ة", "ب" ]

pf()
# Executed in 0.06 second(s) in Ring 1.21
# Executed in 0.14 second(s) in Ring 1.18
# Executed in 0.24 second(s) in Ring 1.17
