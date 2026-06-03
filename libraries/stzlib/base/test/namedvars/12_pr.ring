# Narrative
# --------
# pr()
#
# Extracted from stznamedvarstest.ring, block #12.

load "../../stzBase.ring"

pr()

Vr( "a" : "z" ) '=' Vl( 1 : NumberOfLatinLetters() )
? v(:t)
#--> 20

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.11 second(s) in ring 1.21
