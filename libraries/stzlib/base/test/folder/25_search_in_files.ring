# Narrative
# --------
# We can even search inside text files for a word
#
# Extracted from stzfoldertest.ring, block #25.
# Portable: runs against the local testarea fixture (test.txt and the two
# tempo/*.txt files contain the word "program" on known lines).

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t25"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)

# Results return the full path of each matching file and the 1-based line
# numbers where the word appears.

? @@NL( o1.DeepSearchInFiles("program") )
#-->
'
[
	[ "<testarea>/test.txt",        [ 1, 3 ] ],
	[ "<testarea>/tempo/temp1.txt", [ 1, 3 ] ],
	[ "<testarea>/tempo/temp2.txt", [ 2 ]    ]
]
'

RemoveTestArea(cTA)

pf()
# Executed in 0.01 second(s) in Ring 1.23
