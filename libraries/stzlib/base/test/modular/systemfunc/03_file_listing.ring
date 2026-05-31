# Narrative
# --------
# File listing
#
# Extracted from stzsystemfunctest.ring, block #3.

load "../../../stzBase.ring"


pr()

if isWindows()
	? ShowShortNL( split(
		stzsystem("cmd.exe", ["/c", "dir", "/B"])
	, NL ) )
else
	? ShowShortNL( split(
		stzsystem("ls", ["-la"]) )
	, NL ) )
ok
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
# Executed in 0.06 second(s) in Ring 1.24
