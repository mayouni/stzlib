# Narrative
# --------
# pr()
#
# Extracted from stzRegexTest.ring, block #18.

load "../../stzBase.ring"

pr()

oRegex = new stzRegex("\[(?:[^\[\]]+|(?R))*\]")
 
cTest = "[1,[2,[3,4],[5]],6]"

? oRegex.MatchRecursive(cTest)      
#--> TRUE

? @@NL( oRegex.RecursiveMatchInfo()  )
#--> [
# [
#	[ "isrecursive", 1 ],
#	[ "depth", 4 ],
#	[ "matches", [
#		[ "[1,[2,[3,4],[5]],6]", [ 1, 19 ] ],
#		[ "[2,[3,4],[5]]", [ 4, 16 ] ],
#		[ "[3,4]", [ 7, 11 ] ],
#		[ "[5]", [ 13, 15 ] ]
#	] ]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
