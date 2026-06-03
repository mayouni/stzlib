# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #256.

load "../../stzBase.ring"

pr()

o1 = new stzString("

ABCDEF
GHIJKL
123346
MNOPQU
RSTUVW
984332

")

? @@( o1.TrimQ().
	LinesQ().
	RemoveWXTQ("Q(@char).IsNumberInString()").
	Content()
)
#--> [ "ABCDEF", "GHIJKL", "MNOPQU", "RSTUVW" ]

pf()
# Executed in 0.12 second(s) in Ring 1.22
