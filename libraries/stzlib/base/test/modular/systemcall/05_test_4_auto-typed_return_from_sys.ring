# Narrative
# --------
# TEST 4: Auto-typed return from Sys()
#
# Extracted from stzsystemcalltest.ring, block #5.

load "../../../stzBase.ring"


pr()

# Sys() returns string with @RETURN:list suffix
# stzSystemCall auto-detects and converts

o1 = new stzSystemCall(Sys(:ListFiles))
o1.Run()

# Files in systest/ (auto-converted to list)
acFiles = o1.Output()
? type(acFiles)
#--> LIST

? ShowShortNL( acFiles)
#-->
'
[
	"banking_corporate.stzstyl", 
	"bank_structure.stzorg", 
	"bigtext.txt", 
	"...", 
	"test_diagram.mmd", 
	"test_diagram.stzdiag", 
	"txtfiles"
]
'

pf()
# Executed in 0.12 second(s) in Ring 1.24
