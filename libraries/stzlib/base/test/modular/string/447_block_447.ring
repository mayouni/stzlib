# Narrative
# --------
# #narration
#
# Extracted from stzStringTest.ring, block #447.

load "../../../stzBase.ring"


pr()

# Five nice usecases of the / operator on a Softanza string:

# Use case 1: Dividing the string into 3 equal parts

? Q("RingRingRing") / 3
#--> [ "Ring", "Ring", "Ring" ]

# Use case 2: Splitting the string using a given char

? Q("Ring;Python;Ruby") / ";"
#--> [ "Ring", "Python", "Ruby" ]

# Use case 3: Splitting the string at chars that satisfy a condition

? Q("Ring:Python;Ruby") / WXT('Q(@Char).IsNotLetter()')
#--> [ "Ring", "Python", "Ruby" ]

# Use case 4: Distributing the string equally among three stakeholders

? @@( Q("RingRubyJava") / [ "Qute", "Nice", "Good" ] ) + NL
#--> [ [ "Qute", "Ring" ], [ "Nice", "Ruby" ], [ "Good", "Java" ] ]

# Usecase 5: Allocating chars to stakeholders based on specified portions

? @@( Q("IAmRingDeveloper") / [
	:Subject = 1,
	:Verb    = 2,
	:Noun1   = 4,
	:Noun2   = :RemainingChars
])
#--> [ :Subject = "I", :Verb = "Am", :Noun1 = "Ring", :Noun2 = "Developer" ]

pf()
# Executed in 0.20 second(s) in Ring 1.21
