# Narrative
# --------
# pr()
#
# Extracted from stznamedvarstest.ring, block #6.

load "../../stzBase.ring"

pr()

? @@( tempval() )
#--> ""
? @@( oldval() )
#--> ""

vr([ :name ]) '=' vl([ "mansour" ])

? v(:name)
#--> mansour

? @@( tempval() )
#--> mansour
? @@( oldval() )
#--> mansour
	
setV(:name = "cherihen")
? v(:name)
#--> cherihen

? @@( tempval() )
#--> cherihen
? @@( oldval() )
#--> mansour

? @@( tempvarname() ) # same as tempvar()
#--> name

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.20
