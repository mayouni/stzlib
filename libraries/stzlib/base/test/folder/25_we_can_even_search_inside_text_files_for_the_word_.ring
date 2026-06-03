# Narrative
# --------
# # we can even search inside text files for the word program
#
# Extracted from stzfoldertest.ring, block #25.

load "../../stzBase.ring"

pr()

# (restults return the path of the file and the numbers of lines)

? @@NL( o1.DeepSearchInFiles("program") )
#-->
'
[
	[
		"c:/testarea/test.txt",
		[ 1, 3, 5 ]
	],
	[
		"c:/testarea/tempo/temp1.txt",
		[ 1, 3, 5 ]
	],
	[
		"c:/testarea/tempo/temp2.txt",
		[ 2 ]
	]
]
'

pf()
