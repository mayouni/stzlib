# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #3.

load "../../stzBase.ring"


o1 = new stzList([ 2, 4, 8 ])
? o1.EachItemIsA(:Number)
#--> TRUE
? o1.ItemsAre([ :Positive, :Even, :Numbers ])
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 0.09 second(s) in Ring 1.20
