# Narrative
# --------
# o1 = new stzListOfStrings([ "tom", "sam", "dan" ])
#
# Extracted from stzlistofstringstest.ring, block #80.

load "../../stzBase.ring"

? o1.ContainsCS("sam", TRUE)	#--> TRUE
? o1.ContainsCS("SAM", TRUE)	#--> FALSE
? o1.ContainsCS("SAM", :CS = FALSE)	#--> TRUE
