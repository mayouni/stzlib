# Narrative
# --------
# pr()
#
# Extracted from stzchardatatest.ring, block #3.

load "../../../stzBase.ring"


# Do you knwo how many punctuation chars are theer in Unicode?
? NumberOfPunctuationChars()
#--> 250

# See them all:
? ShowShort(PunctuationChars()) + NL
#--> [ " ", " ", " ", "...", "⹽", "⹾", "⹿" ]

# Unciode classifies them in two blocks: General and Supplemental.
# Let's see...

? NumberOfGeneralPunctuationChars()
#--> 111

# They are liste here:
? ShowShort(GeneralPunctuationChars()) + NL
#--> [ " ", " ", " ", "...", "⁭", "⁮", "⁯" ]

? NumberOfSupplementalPunctuationChars()
#--> 138

# You can see them here:
? ShowShort(SupplementalPunctuationChars())
#--> [ "ⷶ", "ⷷ", "ⷸ", "...", "⹽", "⹾", "⹿" ]

pf()
# Executed in 0.05 second(s) in Ring 1.26 (Backed by StzEngine)
# Executed in 1.85 second(s) in Ring 1.23
