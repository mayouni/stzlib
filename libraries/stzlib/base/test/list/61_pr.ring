# Narrative
# --------
# More L() ranges: native ":" vs L() across reals, negatives, and Unicode.
#
# Contrasts Ring's ":" (1:3 -> integers; 2.8:3.2 -> just the integer endpoints)
# with L(), which steps through real numbers at the endpoints' decimal
# granularity (2.8:3.2 -> 2.80,2.90,3,3.10,3.20), handles negative real ranges
# (-3.25:-3.20), numbered/Unicode tokens ("v1":"v3", "♥1":"♥5", "A":"E"), and
# long Arabic letter ranges (shown abbreviated via ShowShort). "#o-->" lines
# are observed terminal renderings -- correct values, console display only.
#
# Extracted from stzlisttest.ring, block #61.

load "../../stzBase.ring"

pr()

? 1 : 3
#--> [ 1, 2, 3 ]

? 2.8 : 3.2
#--> [ 2, 3 ]

? L('2.8 : 3.2')
#--> [ 2.80, 2.90, 3, 3.10, 3.20 ]

? L('0.07 : 0.10')
#--> [ 0.07, 0.08, 0.09, 0.10 ]

? L(' -3.25 : -3.2 ')
#--> [ -3.25, -3.24, -3.23, -3.22, -3.21, -3.20 ]

? L(' "v1" : "v3" ')
#--> [ "v1", "v2", "v3" ]

? L(' "♥1" : "♥5" ')
#--> [ "♥1", "♥2", "♥3", "♥4", "♥5" ]

? L(' "A" : "E" ')
#--> [ "A", "B", "C", "D", "E" ]

ShowShort( L(' "ج" : "ه" ') )
#o--> [ "ج", "ح", "خ", "...", "م", "ن", "ه" ]

? L(' "كلمة1" : "كلمة3" ')
#o--> [ "كلمة3", "كلمة2", "كلمة1" ]

pf()
# Executed in 0.65 second(s)
