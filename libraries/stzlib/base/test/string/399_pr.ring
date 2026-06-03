# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #399.

load "../../stzBase.ring"


o1 = new stzString("hello")
? o1.NumberOfSubStrings()
#--> 15

? @@( o1.SubStrings() )
#--> [
#	"h", "he", "hel", "hell", "hello",
#	"e", "el", "ell", "ello",
#	"l", "ll", "llo", "l", "lo",
#	"o"
# ]

pf()
# Executed in 0.06 second(s)
