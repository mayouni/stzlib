# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #477.

load "../../../stzBase.ring"


? Q("str").AllCharsAre(:Chars)
#--> TRUE

? Q("str").AllCharsAre(:Strings)
#--> TRUE

? Q("123").AllCharsAre(:Numbers)
#--> TRUE

? Q("(,)").AllCharsAre(:Punctuations)
#--> TRUE

? Q("نور").AllCharsAre(:Arabic)
#--> TRUE

? Q("نور").AllCharsAre(:RightToLeft)
#--> TRUE

? Q("LOVE").AllCharsAre(:Invertible)
#--> TRUE

? Q("LOVE").CharsInverted()
#--> ƎɅO⅂

pf()
# Executed in 2.71 second(s).
