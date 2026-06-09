# Narrative
# --------
# String variations with proper escaping
#
# Extracted from stzextercodetest.ring, block #4.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oPyCode = new stzExterCode("python")
oPyCode.setCode('
res = {
    "simple": "Hello World",
    "multiline": "First line\\nSecond line\\nThird line",
    "spaces": "   padded   ",
    "mixed_text": "Numbers: 123, Symbols: @#$%"
}
')

oPyCode.Exec()

? @@(oPyCode.Result())
#--> [
#	[ "simple", "Hello World" ],
#	[ "multiline", "First line
# Second line
# Third line" ],
#	[ "spaces", "   padded   " ],
#	[ "mixed_text", "Numbers: 123, Symbols: @#$%" ]
# ]

pf()
# Executed in 0.16 second(s) in Ring 1.23
