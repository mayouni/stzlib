# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #15.

load "../../stzBase.ring"


? @@( ArabicDotlessUnicodes() ) + NL
#--> [
#	1609, 1575, 1581, 1583, 1585,
#	1587, 1589, 1591, 1593, 1605,
#	1607, 1608, 1646, 1647, 1697,
#	1705, 1722
# ]

? @@( ArabicDotlessLetters() ) + NL
#--> [ "ى", "ا", "ح", "د", "ر", "س", "ص", "ط", "ع", "م", "ه", "و", "ٮ", "ٯ", "ڡ", "ک", "ں" ]

? @@( LatinDotlessUnicodes() ) + NL
#--> [ 305, 567 ]

? @@( LatinDotlessLetters() )
#--> [ "ı", "ȷ" ]

pf()
# Executed in 0.03 second(s) in Ring 1.23
# Executed in 0.74 second(s) in Ring 1.19
