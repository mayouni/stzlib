# Narrative
# --------
# # we can even search inside text files for the word program
#
# Extracted from stzfoldertest.ring, block #25.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

# Self-contained sandbox fixture (the extraction dropped the o1 setup and
# assumed a machine-specific c:/testarea/test.txt).
cSrchSbx = CurrentDir() + "/_fx_srch"
if dirExists(cSrchSbx) RemoveFolderRecursive(cSrchSbx) ok
QMkdir(cSrchSbx)
write(cSrchSbx + "/test.txt", "program starts here" + nl + "second line" + nl + "program ends")
o1 = new stzFolder(cSrchSbx)

# (results return the path of the file and the numbers of lines)

? @@NL( o1.DeepSearchInFiles("program") )

if dirExists(cSrchSbx) RemoveFolderRecursive(cSrchSbx) ok
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
