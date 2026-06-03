# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #762.

load "../../stzBase.ring"

pr()

StzStringQ("What a tutorial! Very instructive tutorial.") {

	? FindAll("tutorial")
	#--> [ 8, 35 ]

	? NumberOfOccurrence("tutorial") + NL
	#--> 2

	? FindNextOccurrence("tutorial", :StartingAt = 20) + NL
	#--> 35

	? FindPreviousOccurrence("tutorial", :StartingAt = 20) + NL
	#--> 8

	? NumberOfChars() + NL
	#--> 43
	 
	? @@( SplitToPartsOfNChars(12) ) + NL
	#--> [
	# 	"What a tutor",
	# 	"ial! Very in",
	# 	"structive tu",
	# 	"torial."
	#    ]

	? @@( SplitBeforePositions([ 17, 34 ]) ) + NL
	#--> [
	# 	"What a tutorial!",
	# 	" Very instructive",
	# 	" tutorial."
	#    ]

	? @@( SplitBeforeCharsWXT(' @char = "a" ') ) + NL
	#--> [
	# 	"Wh", "at ", "a tutori",
	# 	"al! Very instructive tutori", "al."
	#     ]

}

pf()
# Executed in 0.25 second(s).
