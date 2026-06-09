# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #114.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

txt = "dear ‮friends!"

o1 = new stzString(txt)
o1 {
	? Content()
	#--> dear ‮friends!

	? @@NL(CharsNames()) + NL

	? ContainsInvisibleChars()
	#-- TRUE

	? @@(o1.FindInvisibleChars())
	#-- [ 6 ]

	? @@(o1.InvisibleChars())
	#--> [ "RIGHT-TO-LEFT OVERRIDE" ]
}

# As you see, it's called "RIGHT-TO-LEFT OVERRIDE"
# It's an inivisble char and turn the text after it right-to-left

# All insible chars

? InvisibleCharsNames()
#-->
'
<control>
NO-BREAK SPACE
EN QUAD
EM QUAD
EN SPACE
EM SPACE
THREE-PER-EM SPACE
FOUR-PER-EM SPACE
SIX-PER-EM SPACE
FIGURE SPACE
PUNCTUATION SPACE
THIN SPACE
HAIR SPACE
ZERO WIDTH SPACE
ZERO WIDTH NON-JOINER
ZERO WIDTH JOINER
LEFT-TO-RIGHT MARK
RIGHT-TO-LEFT MARK
LINE SEPARATOR
PARAGRAPH SEPARATOR
RIGHT-TO-LEFT OVERRIDE
NARROW NO-BREAK SPACE
MEDIUM MATHEMATICAL SPACE
IDEOGRAPHIC SPACE
HANGUL FILLER
HANGUL CHOSEONG FILLER
HALFWIDTH HANGUL FILLER
'

pf()
# Executed in 3.97 second(s) in Ring 1.23
