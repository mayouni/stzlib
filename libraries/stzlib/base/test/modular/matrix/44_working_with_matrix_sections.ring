# Narrative
# --------
# WORKING WITH MATRIX SECTIONS
#
# Extracted from stzmatrixtest.ring, block #44.

load "../../../stzBase.ring"


pr()

o1 = new stzMatrix([
	[ 14, 20, 16 ],
	[ 14, 20, 16 ],
	[ 17, 23, 19 ],
])

? @@( o1.Section([ 1, 1 ], [ 2, 2 ]) )
#--> [ 14, 14, 20, 20 ]

# SectionQ() returns a stzList object

? o1.SectionQ([ 1, 1 ], [ 2, 2 ]).StzType()
#--> stzlist

# More interestingly SectionQQ() returns a stzListOfNumbers
# that you can chain on to make various operations

o1.SectionQQ([ 1, 1 ], [ 2, 2 ]) {
	? Max()	#--> 20
	? Min()	#--> 14
	? Sum()	#--> 68
}

pf()
# Executed in 0.02 second(s) in Ring 1.22
