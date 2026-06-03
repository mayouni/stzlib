# Narrative
# --------
# o1 = new stzListOfStrings( functions() )
#
# Extracted from stzlistofstringstest.ring, block #25.

load "../../../stzBase.ring"

? o1.ContainsCS("StzRaise", :CS = FALSE)	#--> TRUE
? o1.FindFirstcs("StzRaise", :CS = FALSE)	#--> 318
