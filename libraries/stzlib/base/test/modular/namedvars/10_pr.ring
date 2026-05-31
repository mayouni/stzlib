# Narrative
# --------
# pr()
#
# Extracted from stznamedvarstest.ring, block #10.

load "../../../stzBase.ring"


Vr([ :name1, :name2, :name2 ]) '=' Vl([ "Hussein", "Haneen" ])
? v([ :name1, :name2, :name7 ])
#--> ERROR: Undefined named variable!

pf()
