# Narrative
# --------
# #ring
#
# Extracted from stznamedvarstest.ring, block #16.

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

class Point { x=10 y=10 z=10 }

# Executed in almost 0 second(s) in Ring 1.23
