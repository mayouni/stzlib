# Narrative
# --------
# pr()
#
# Extracted from stznamedvarstest.ring, block #9.

load "../../stzBase.ring"

pr()

Vr([ :name1, :name2, :name2 ]) '=' Vl([ "Hussein", "Haneen" ])
? v(:name)
#--> ERROR: Undefined named variable!

pf()
