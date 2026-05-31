# Narrative
# --------
# #TODO Review implementation
#
# Extracted from stznumbertest.ring, block #70.

load "../../../stzBase.ring"


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

pf()
