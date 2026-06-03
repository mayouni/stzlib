# Narrative
# --------
# pr()
#
# Extracted from stzsystemcalltest.ring, block #18.

load "../../stzBase.ring"


# Find files
oCall = new stzSystemCall(Sys(:FindFiles)) 
oCall.SetParam(:pattern, "*.txt")
oCall.Run()

# Text files found:
? ShowShortNL( oCall.Output() ) # when we use Sys() the type oof output is automatic
#-->
'
[
	"D:\GitHub\stzlib\libraries\stzlib\base\test\bigtext.txt", 
	"D:\GitHub\stzlib\libraries\stzlib\base\test\config.txt", 
	"D:\GitHub\stzlib\libraries\stzlib\base\test\log.txt", 
	"...", 
	"D:\GitHub\stzlib\libraries\stzlib\base\test\systest\newdir\moved.txt", 
	"D:\GitHub\stzlib\libraries\stzlib\base\test\txtfiles\test.txt", 
	"D:\GitHub\stzlib\libraries\stzlib\base\test\txtfiles\test_output.txt"
]
'

pf()
# Executed in 0.05 second(s) in Ring 1.24
