# Narrative
# --------
#
# Extracted from stzhashlisttest.ring, block #24.

load "../../stzBase.ring"

pr()

o1 = new stzHashList([ [ "NAME", "Mansour"] , [ "AGE" , 45 ] ])
? @@( o1.Content() ) # Keys are automatically lowercased
#--> [ [ "name", "Mansour" ], [ "age", 45 ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.19
