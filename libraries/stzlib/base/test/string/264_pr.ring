# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #264.

load "../../stzBase.ring"


o1 = new stzList([
	"ABCDEF",
	"GHIJKL",
	"123346",
	"MNOPQU",
	"RSTUVW",
	"984332"
])

? o1.FindWXT(' @IsNumberInString(@item) ')
#--> [ 3, 6 ]

pf()
# Executed in 0.13 second(s) in Ring 1.22
