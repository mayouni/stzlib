# Narrative
# --------
# ALTERNATION: MULTIPLE PROPERTIES
#
# Extracted from stznumbrextest.ring, block #15.

load "../../stzBase.ring"


pr()

Nx = Nx("{@Property(Perfect) | @Property(Fibonacci) | @Property(Palindrome)}")
? Nx.Match(6)    #--> TRUE (perfect)
? Nx.Match(13)   #--> TRUE (fibonacci)
? Nx.Match(121)  #--> TRUE (palindrome)
? Nx.Match(10)   #--> FALSE (none)

pf()
