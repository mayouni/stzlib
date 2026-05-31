# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #49.

load "../../../stzBase.ring"


anInvertibles = InvertibleUnicodes()

? len(anInvertibles)
#--> 141

? ShowShort(anInvertibles) #TODO // Remove the NL at the end of the string
#-- [ 36, 38, 40, "...", 43843, 43856, 43857 ]

? Showshort(InvertibleChars())
#--> [ "$", "&", "(", "...", "ꭃ", "ꭐ", "ꭑ" ]

pf()
# Executed in 0.04 second(s) in Ring 1.23
