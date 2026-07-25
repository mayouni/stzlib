# Narrative
# --------
# #TODO Review implementation
#
# Extracted from stznumbertest.ring, block #70.
#ERR Error (R14) : Calling Method without definition: repeatedtrailingcharis

load "../../stzBase.ring"


pr()

o1 = new stzNumber(12590)
? o1.ApplyFormatXT([
	# Precision
	:RestrictFractionalPart = FALSE,
	:NumberOfDigitsInFractionalPart = 5,
	:RoundItWhenRestricted = FALSE,

	# Round
	:ApplyRound = TRUE,
	:RoundTo = 5, # !! change this to 2 ans see result

	# Adjustment
	:Width = 15,
	:FillBlanksWith = " ",

	:AlignTo = :Center, # :Left, :Right
	:FixPrefixToLeft = TRUE,
	:FixSuffixToRight = FALSE,
	
	# Sign
	:ShowSign = TRUE,
	:PutNegativeBetweenParentheses = TRUE,

	# Prefix, separators, and suffix
	:Prefix = "$",

	:ThousandsSeparator = ".",
	:FractionalSeparator = ",",

	:Suffix = NULL,

	# Conversion
	:ToPercentage = FALSE,
	:ToScientificNotation,

	:ToHex,
	:ToBinary,
	:ToOctal,
	:ToBase = 0,

	:ToIndian,
	:ToRoman
])
#--> +$12.590
#
# RECORDED 2026-07-25, having never been recorded before. This printed nothing at
# all until cd0685cfd (a dead call in Structure()), then printed +$12.59.0 until the
# digit grouping was fixed -- Structure() split the integer part into THREE PARTS
# rather than parts OF three, so 12590 came apart as 12/59/0.
#
# NOTE what is NOT in that output: :Width = 15, :AlignTo = :Center and
# :FillBlanksWith are read from the options above and then never used, so the result
# is not padded to 15 characters. That is an unimplemented feature rather than a
# wrong answer, and it is why this line is 8 characters and not 15.

pf()
