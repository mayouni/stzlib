# Narrative
# --------
# CONJUNCTION: MULTIPLE CONDITIONS
#
# Extracted from stznumbrextest.ring, block #18.

load "../../stzBase.ring"


pr()

Nx = Nx("{@Property(Even) & @Digit3 & @Property(Palindrome)}")
? Nx.Match(212)  #--> TRUE
? Nx.Match(222)  #--> TRUE
? Nx.Match(213)  #--> FALSE (not palindrome)

pf()
