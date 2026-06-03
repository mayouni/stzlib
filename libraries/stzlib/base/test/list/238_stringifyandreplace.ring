# Narrative
# --------
# #internal
#
# Extracted from stzlisttest.ring, block #238.

load "../../stzBase.ring"


pr()

aList = [ 10, 20, "One", "ONE", [ :Tunis, :Paris ], 30, "two" ]
	for i = 1 to 10
		aList + ("*"+i)
	next
	aLarge + "in" + "out" + "IN" + "OUT"

o1 = new stzList(aList)

? @@( o1.StringifyAndReplaceQ(",", "*").Content() )
#--> [
#	"10", "20", "One", "ONE",
#	'[ "tunis"* "paris" ]',
#	"30", "two",
#
#	"__*1__",
#	"__*2__",
#	"__*3__",
#	"__*4__",
#	"__*5__",
#	"__*6__",
#	"__*7__",
#	"__*8__",
#	"__*9__",
#	"__*10__",
#
#	"in", "out", "IN", "OUT" ]
# ]

? o1.ContainsDuplicates()
#--> FALSE

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.17
