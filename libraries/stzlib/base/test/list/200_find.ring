# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #200.

load "../../stzBase.ring"

pr()

o1 = new stzList(
	1:299_000 + "str1" + "str2" + 12 + [ "*", "+" ] + "str1" + o1 +  [ "*", "+" ]
)

? o1.Find([ "*", "+" ] )
#--> [299004, 299007]

pf()
# Executed in 0.84 second(s)
