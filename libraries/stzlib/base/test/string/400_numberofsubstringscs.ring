# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #400.
#ERR Error (R19) : Calling function with less number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("hello")
? o1.NumberOfSubStringsCS(FALSE)
#--> 14

? @@( o1.SubStringsCS(FALSE) )
#--> [
#	"h", "he", "hel", "hell", "hello",
#	"e", "el", "ell", "ello",
#	"l", "ll", "llo", "lo",
#	"o"
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.54 second(s) in Ring 1.18
