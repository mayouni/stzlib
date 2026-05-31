# Narrative
# --------
# pr()
#
# Extracted from stzlistofcharstest.ring, block #4.

load "../../../stzBase.ring"


? StzListOfCharsQ("A":"E").IsContiguous()
#--> TRUE

? StzListOfCharsQ("1":"5").IsContiguous()
#--> TRUE

? StzListOfCharsQ('"ا":"ج"').IsContiguous()
#--> TRUE	TODO: ERROR!

pf()
# Executed in 0.07 second(s).
