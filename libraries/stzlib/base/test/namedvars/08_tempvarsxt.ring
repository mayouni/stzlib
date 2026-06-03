# Narrative
# --------
# pr()
#
# Extracted from stznamedvarstest.ring, block #8.

load "../../stzBase.ring"

pr()

Vr([ :name1, :name2, :name3 ]) '=' Vl([ "Hussein", "Haneen" ])
? @@( TempVarsXT() )
#--> [ :say = null, :name1 = "Hussein", :name2 = "Haneen", :name3 = "" ])

? @@( v(:name3) )
#--> ""

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.20
