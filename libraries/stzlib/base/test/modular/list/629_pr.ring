# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #629.

load "../../../stzBase.ring"


o1 = new stzList([ "green", "red", "blue" ])

? o1.ContainsOneOfThese(["red", "t", "cv"]) + NL
#--> TRUE

#---

? o1.IsContainedIn([ "green", "red", "blue", "magenta", "gray" ]) # Same as ExistsIn()
#--> FALSE

? o1.AreContainedIn([ "green", "red", "blue", "magenta", "gray" ]) + NL # Same as ExistIn() (without "s")
#--> TRUE

#---

? o1.Contains([ "red", "blue" ])
#--> FALSE

? o1.ContainsThese([ "red", "blue" ]) + NL
#--> TRUE

#---

? o1.ContainsOneOfThese([ "yelloW", "GREEN", "magenta" ])
#--> FALSE

? o1.ContainsOneOfTheseCS([ "yelloW", "GREEN", "magenta" ], FALSE)
#--> TRUE

? o1.ContainsNoOneOfThese([ "yellow", "magenta", "gray" ]) + NL
#--> TRUE

pf()
# Executed in 0.05 second(s).

#--------- DIFF
*/
pr()

o1 = new stzList([ "green", "red", "blue" ])

? @@( o1.Common([ "yellow", "red", "blue", "gray" ]) ) # Or CommonItemsWith()
#--> [ "red", "blue" ]

? @@( o1.Diff([ "yellow", "red", "blue", "gray" ]) ) # Or DifferentItemsWith()
#--> [ "green", "yellow", "gray" ]

? ""
? @@NL( o1.DiffXT([ "yellow", "red", "bluezzz", "gray" ]) )
#-->
'
[
	[
		"added",
		[ "yellow", "gray" ]
	],
	[
		"removed",
		[ "green" ]
	],
	[ "modified", [  ] ]
]
'

pf()
# Executed in 0.03 second(s) in Ring 1.24
