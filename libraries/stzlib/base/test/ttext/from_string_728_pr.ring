# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #728.
#ERR Error (R14) : Calling Method without definition: containsscript

load "../../stzBase.ring"

pr()

? StzTextQ("abc سلام abc").ContainsScript(:Arabic)
#--> TRUE

? StzTextQ("abc سلام abc").ContainsArabicScript()
#--> TRUE

#NOTE: Scripts are now moved from stzString to stzText

# You can use this short form instead of StzTextQ()
? TQ("سلام").Script() #--> :Arabic

pf()
# Executed in 0.07 second(s).
