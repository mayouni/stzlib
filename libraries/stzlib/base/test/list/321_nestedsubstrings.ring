# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #321.
#ERR Error (R14) : Calling Method without definition: nestedsubstrings

load "../../stzBase.ring"

pr()

o1 = new stzString('[[[
	"1", "1",
		[[[ "2", "♥", "2" ]]],
	"1",
		[[[ "2",
			[[[ "3", "♥",
				[[[ "4",
					[[[ "5", "♥" ]]],
				"4",
					[[[ "5", "♥" ]]],
				"♥" ]]],
			"3" ]]]
		]]]

]]]')

o1.Simplify() # To remove NLs, TABs and overspaces from the string

? @@NL( o1.NestedSubStrings(:BoundedBy = [ "[[[", "]]]" ]) ) 		# Or DeepSubStrings() or SubStringsBoundedBy()
#--> [
#	' "1", "1", ',
#	' "2", "♥", "2" ',
#	', "1", ',
#	' "2", ',
#	' "3", "♥", ',
#	' "4", ',
#	' "5", "♥" ',
#	', "4", ',
#	' "5", "♥" ',
#	', "♥" ',
#	', "3" ',
#	" ",
#	" "
# ]

? SpeedUpX(12.72, 0.06) # Ring 1.21 is 200X more performant!
#--> 212.00

StopProfiler()

pf()
# Executed in  0.06 second(s) in Ring 1.21
# Executed in 12.72 second(s) in Ring 1.17
