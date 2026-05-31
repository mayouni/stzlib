# Narrative
# --------
# Showing the short form of a long list
#
# Extracted from stzGlobalTest.ring, block #24.

load "../../../stzBase.ring"


pr()

? @@( "A" : "Z" ) + NL
#--> [
#	"A", "B", "C", "D",
#	"E", "F", "G", "H",
#	"I", "J", "K", "L",
#	"M", "N", "O", "P",
#	"Q", "R", "S", "T",
#	"U", "V", "W", "X",
#	"Y", "Z"
# ]

# Showing a part of a long list

? @@S( "A" : "Z" ) + NL
#--> [ "A", "B", "C", "...", "X", "Y", "Z" ]

? @@S(1:100_000) + NL
#--> [ 1, 2, 3, "...", 99998, 99999, 100000 ]

# Showing the 2 first items and 2 last items of a long list

? @@SXT(1:50, 2) + NL
#--> [ 1, 2, "...", 49, 50 ]

# Showing the 2 first items and the 3 last items of a long list

? @@SXT(1:50, [2, 3]) + NL
#--> [ 1, 2, "...", 48, 49, 50 ]

pf()
#--> Executed in 0.01 second(s) in Ring 1.21
#--> Executed in 0.10 second(s) in Rin 1.20
