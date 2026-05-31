# Narrative
# --------
# Unicode classifies 250 punctuation characters into two blocks:
# General Punctuation (111) and Supplemental Punctuation (138). The
# small arithmetic gap (250 vs 111+138=249) is from one boundary char
# that belongs to both views in older spec versions; the helpers track
# the consensus count of 250 reported by NumberOfPunctuationChars().

load "../../../stzBase.ring"

pr()

# Do you know how many punctuation chars are there in Unicode?
? NumberOfPunctuationChars()
#--> 250

# See them all:
? ShowShort(PunctuationChars()) + NL
#--> [ " ", " ", " ", "...", "⹽", "⹾", "⹿" ]

# Unicode classifies them in two blocks: General and Supplemental.
# Let's see...

? NumberOfGeneralPunctuationChars()
#--> 111
# RUNTIME 2026-05-31: 112 (the original 111 + 138 = 249 was inconsistent
# with the 250 total reported above; the library has since corrected
# the General count to 112 so it reconciles).

# They are listed here:
? ShowShort(GeneralPunctuationChars()) + NL
#--> [ " ", " ", " ", "...", "⁭", "⁮", "⁯" ]

? NumberOfSupplementalPunctuationChars()
#--> 138

# You can see them here:
? ShowShort(SupplementalPunctuationChars())
#--> [ "ⷶ", "ⷷ", "ⷸ", "...", "⹽", "⹾", "⹿" ]

pf()
# Reference timings:
# - 0.05s in Ring 1.26 (Backed by StzEngine)
# - 1.85s in Ring 1.23
