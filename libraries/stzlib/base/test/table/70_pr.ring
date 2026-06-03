# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #70.

load "../../stzBase.ring"


o1 = new stzListOfLists([
	[ 10, "Abdelkarim", 52 ],
	[ 20, "Hatem", 46 ],
	[ 30, "Abraham", 48 ]
])

o1.SortOnBy(2, "len(@item)")

? @@NL( o1.Content() )
#--> [
#	[ 20, "Hatem", 46 ],
#	[ 30, "Abraham", 48 ],
#	[ 10, "Abdelkarim", 52 ]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.24
