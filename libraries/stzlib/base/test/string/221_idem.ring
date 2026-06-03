# Narrative
# --------
# #TODO Idem
#
# Extracted from stzStringTest.ring, block #221.
#ERR Error (R14) : Calling Method without definition: lettersq

load "../../stzBase.ring"


pr()

? @@( Q("ring is owsome!").UppercaseQ().LettersQ().YieldWXT('[ @item, ascii(@item) - 65 ]') )
#--> [
#	[ "R", 17 ], [ "I", 8  ], [ "N", 13 ],
#	[ "G", 6  ], [ "I", 8  ], [ "S", 18 ],
#	[ "O", 14 ], [ "W", 22 ], [ "S", 18 ],
#	[ "O", 14 ], [ "M", 12 ], [ "E", 4  ]
# ]
pf()
