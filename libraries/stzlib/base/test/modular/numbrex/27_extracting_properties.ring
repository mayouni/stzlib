# Narrative
# --------
# EXTRACTING PROPERTIES
#
# Extracted from stznumbrextest.ring, block #27.

load "../../../stzBase.ring"


pr()

Nx = Nx("{@Property(Even)}")

? Nx.Match(6)
#--> TRUE

? @@( Nx.Properties() )
#--> [ "Even", "Perfect", "Palindrome", "Triangular", "Composite" ]

? Nx.Value()
#--> 6

pf()
