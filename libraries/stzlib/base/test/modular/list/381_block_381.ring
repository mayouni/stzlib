# Narrative
# --------
# *
#
# Extracted from stzlisttest.ring, block #381.

load "../../../stzBase.ring"

pr()

o1 = new stzList([ 1:3, 4:6, 1:3, 1:3, 4:6, 7:10 ])

o1.Removeduplicates()
? @@( o1.Content() )
#--> Executed in almost 0 second(s) in Ring 1.22

pf()
# Executed in almost 0 second(s).
