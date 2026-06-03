# Narrative
# --------
# #ring #ref
#
# Extracted from stzuuidtest.ring, block #8.

load "../../stzBase.ring"


pr()

oMyPoint = new Point
aInnerList = [1, 2, 3]

aList = [ 22, ref(oMyPoint), "B", ref(aInnerList) ]

? find(aList, 22) 		#--> 1
? find(aList, "B")		#--> 3
? find(aList, aInnerList) 	#--> 2
? find(aList, oMyPoint)		#--> 4

pf()
# Executed in almost 0 second(s) in Ring 1.24

class Point { x=10 y=10 z=10 }
