# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #29.

load "../../../stzBase.ring"


o1 = new stzTable([
	:col1 = [ "I", 1 ],
	:col2 = [ AHeart(), 2 ],
	:Col3 = [ "Ring", 3 ],
	:Col4 = [ "Language", 4 ]
])

? o1.Show()
#-->
#	COL1   COL2   COL3       COL4
#	----- ------ ------ ---------
#	  I      ♥   Ring   Language
#	  1      2      3          4

pf()
# Executed in 0.12 second(s)
