# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #322.

load "../../stzBase.ring"

pr()

o1 = new stzString('[[[
	"1", "1",
		[[["2", "♥", "2"]]],
	"1",
		[[["2",
			[[["3", "♥",
				[[["4",
					[[["5", "♥"]]],
				"4",
					[[["5","♥"]]],
				"♥"]]],
			"3"]]]
		]]]

]]]')

? @@( o1.FindSubStringsBoundedByIBZZ([ "[[[", "]]]" ]) ) + NL
#--> [ [ 1, 36 ], [ 47, 101 ], [ 118, 130 ] ]

? @@NL( o1.SubStringsBoundedByIB([ "[[[", "]]]" ]) )

#--> [
#	'[[[
#		"1", "1",
#			[[["2", "♥", "2"]]]',
#
#	#--
#
#	'[[["2",
#				[[["3", "♥",
#					[[["4",
#						[[["5", "♥"]]]',
#
#	#--
#
#	'[[["5","♥"]]]'
#
# ]

pf()
# Executed in 0.64 second(s)
