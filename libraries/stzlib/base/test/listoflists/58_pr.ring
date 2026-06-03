# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #58.

load "../../stzBase.ring"


o1 = new stzList([
	[ 1, 2, 3 ],
	[ 4, 5, 6, 7, 8 ],
	[ 9, 0 ],
	[ 3, 5 ],
	[ 5, 6, 7 ]
])

? o1.EachItemIsA(:ListOfNumbers)
#--> TRUE

o1 = new stzList([ "A":"C", "E":"D", "G": "Y" ])
? o1.EachItemIs(:ListOfStrings)
#--> TRUE

? o1.EachItemIs(:ListOfChars)
#--> TRUE

pf()
# Executed in 0.37 second(s)
