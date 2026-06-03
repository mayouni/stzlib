# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #628.

load "../../stzBase.ring"

pr()

o1 = new stzList([ :english = "house", :french = "maison", :arabic = "منزل" ])
? o1.IsMultilingualString()
#--> TRUE

o1 = new stzList([ :en = "house", :fr = "maison", :ar = "منزل" ])
? o1.IsMultilingualString()
#--> TRUE

pf()
# Executed in 0.02 second(s).
