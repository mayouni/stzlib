# Narrative
# --------
# Contrasts Ring's built-in List2Code() with Softanza's ListToCode():
# both turn a live list back into the source-code string that would
# recreate it, but with opposite formatting philosophies.
#
# List2Code() pretty-prints vertically: one element per line, tab
# indentation, and it escapes embedded double quotes the verbose Ring
# way (""+char(34)+"B"+char(34)+""). ListToCode() emits a compact,
# single-line literal that reads like hand-written Softanza code,
# picking the lighter quote style per string ('"B"' for a value that
# itself holds double quotes, "'C'" for one holding single quotes).
# The compact form is the human-friendly default and is also faster
# on large lists.
#
# Extracted from stzlisttest.ring, block #170.

load "../../stzBase.ring"


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
