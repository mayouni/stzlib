# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #748.

load "../../stzBase.ring"


o1 = new stzString("abc;123;gafsa;ykj")
? o1.SplitQ(";").NthItem(3)
#--> gafsa

# Same as:
? o1.NthSubstringAfterSplittingStringUsing(3, ";") # Long, but useful in natural-coding
#--> gafsa

pf()
# Executed in 0.01 second(s).
