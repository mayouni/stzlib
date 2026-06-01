# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #84.

load "../../../stzBase.ring"


o1 = new stzString("okay one pepsi two three ")
? o1.SplitQ(" ").FindWXT(' Q(@item).ContainsAnyOfThese( Q("vwto").Chars() ) ')
#--> [ 1, 2, 4, 5 ]

pf()
# Executed in 0.21 second(s) in Ring 1.20
# Executed in 0.58 second(s) in Ring 1.17
