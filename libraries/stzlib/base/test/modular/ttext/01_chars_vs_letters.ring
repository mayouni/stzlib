# Narrative
# --------
# Chars() VS Letters()
#
# Extracted from stzTtexttest.ring, block #1.

load "../../../stzBase.ring"


profon()

str = "Пи++е́тو**שָׁ ب d ("
? @@( SQ(str).Chars() ) # Uses stzString
#--> [ "П", "и", "+", "+", "е", "́", "т", "و", "*", "*", "ש", "ָ", "ׁ", " ", "ب", " ", "d", " ", "(" ]

? @@( TQ(str).Letters() ) # Uses stzText
#--> [ "П", "и", "е", "т", "و", "ש", "ب", "d" ]

proff()
