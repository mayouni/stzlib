# Narrative
# --------
# File listing
#
# Extracted from stzsystemfunctest.ring, block #3.
#ERR Error (C3) : Unclosed control structure, 'ok' is missing

load "../../stzBase.ring"


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
	"../_data/banking_corporate.stzstyl", 
	"../_data/bank_structure.stzorg", 
	"../_data/bigtext.txt", 
	"...", 
	"test_diagram.mmd", 
	"test_diagram.stzdiag", 
	"txtfiles"
]
'

pf()
# Executed in 0.06 second(s) in Ring 1.24
