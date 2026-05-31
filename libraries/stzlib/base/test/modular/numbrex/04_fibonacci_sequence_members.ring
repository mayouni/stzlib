# Narrative
# --------
# FIBONACCI SEQUENCE MEMBERS
#
# Extracted from stznumbrextest.ring, block #4.

load "../../../stzBase.ring"


pr()

oFib = Nx("{@Property(Fibonacci)}")
? oFib.Match(13)  #--> TRUE
? oFib.Match(21)  #--> TRUE
? oFib.Match(22)  #--> FALSE

pf()
