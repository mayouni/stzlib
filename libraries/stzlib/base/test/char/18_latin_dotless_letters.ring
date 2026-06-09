# Narrative
# --------
# Latin dotless letters
#
# Extracted from stzchartest.ring, block #18.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr() 

? @@( LatinDotlessLetters() ) + NL
#--> [ "ı", "ȷ" ]

? @@( LatinDotlessUnicodes() ) + NL
#--> [ 305, 567 ]

? @@( LatinDotlessLettersAndTheirUnicodes() ) + NL
#--> [ [ "ı", 305 ], [ "ȷ", 567 ] ]

? @@( LatinDotlessLettersXT() ) + NL
#--> [ [ "ı", "ı" ], [ "i", "ı" ], [ "ȷ", "ȷ" ], [ "j", "ȷ" ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.23
# Executed in 0.08 second(s) in Ring 1.20
