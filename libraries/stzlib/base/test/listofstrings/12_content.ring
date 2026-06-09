# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlistofstringstest.ring, block #12.
#ERR exit 1: Line 156 Bad parameter type!

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([
	"", "",
	"ABCDEF", "GHIJKL",
	"123346", "MNOPQU", "RSTUVW", "984332",
	"", ""
])

o1.RemoveAtQ([5, 8]).TrimQ()
? @@( o1.Content() )
#--> [ "ABCDEF", "GHIJKL", "MNOPQU", "RSTUVW" ]

StopProfiler()

pf()
