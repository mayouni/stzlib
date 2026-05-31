# Narrative
# --------
# #narration Ring List2Code() VS Softanza ListToCode()
#
# Extracted from stzlisttest.ring, block #170.

load "../../../stzBase.ring"


pr()

? List2Code([ [ 6, 8 ], [ 16, 18 ] ]) + NL # Ring standard function
#--> "[
#	[
#		6,
#		8
#	],
#	[
#		16,
#		18
#	]
# ]"

? ListToCode([ [ 6, 8 ], [ 16, 18 ] ]) + NL # Softanza function
#--> "[ [ 6, 8 ], [ 16, 18 ] ]"

? "---" + NL

? List2Code([ "A", '"B"', "'C'" ]) + NL # Ring standard function
#--> [
#	"A",
#	""+char(34)+"B"+char(34)+"",
#	"'C'"
# ]

? ListToCode([ "A", '"B"', "'C'" ]) # Softanza function
#--> [ "A", '"B"', "'C'" ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.20

#NOTE: Also, Softanza version is more performant (testit for a large list)
