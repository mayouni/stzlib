# Narrative
# --------
# str = "ring"
#
# Extracted from stzStringTest.ring, block #86.

load "../../stzBase.ring"

str = ""
for i = 1 to 10000
	str += "ring"
next

pr()

c1 = str[1]
? c1
#--> "r"

c2 = str[len(str)]
? c2
#--> "g"

pf()
# Executed in 0.03 second(s)
