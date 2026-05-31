# Narrative
# --------
# PALINDROMIC NUMBERS
#
# Extracted from stznumbrextest.ring, block #5.

load "../../../stzBase.ring"


pr()

oPalin = Nx("{@Property(Palindrome)}")
? oPalin.Match(121)   #--> TRUE
? oPalin.Match(1221)  #--> TRUE
? oPalin.Match(123)   #--> FALSE

pf()
