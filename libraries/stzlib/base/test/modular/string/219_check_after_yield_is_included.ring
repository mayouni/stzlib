# Narrative
# --------
# #TODO Check after Yield() is included
#
# Extracted from stzStringTest.ring, block #219.

load "../../../stzBase.ring"

*
pr()

# To return the ascii code of each letter we say:
? Q("ring is owsome!").UppercaseQ().LettersQ().YieldWXT('ascii(@item) - 65')
#--> [ 17, 8, 13, 6, 8, 18, 14, 22, 18, 14, 12, 4 ]

# To return the letter along with the asscii code, we write:
? Q("ring is owsome!").UppercaseQ().LettersQ().YieldWXT('[ @item, ascii(@item) - 65 ]')
#--> [
#	[ "R", 17 ], [ "I", 17 ], [ "N", 13 ],
#	[ "G", 6  ], [ "I", 8  ], [ "S", 18 ],
#	[ "O", 14 ], [ "W", 22 ], [ "S", 18 ],
#	[ "O", 14 ], [ "M", 12 ], [ "E", 4  ]
# ]

pf()
# Executed in 3.02 second(s)
