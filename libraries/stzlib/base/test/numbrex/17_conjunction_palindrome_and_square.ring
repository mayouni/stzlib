# Narrative
# --------
# CONJUNCTION: PALINDROME AND SQUARE
#
# Extracted from stznumbrextest.ring, block #17.

load "../../stzBase.ring"


pr()

Nx = Nx("{@Property(Palindrome) & @Property(Square)}")
? Nx.Match(121)  #--> TRUE (11^2 = 121)
? Nx.Match(144)  #--> FALSE (palindrome check: 144 != 441)
? Nx.Match(131)  #--> FALSE (not a square)

pf()
