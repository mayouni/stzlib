# Narrative
# --------
# // TODO - FUTURE //
#
# Extracted from stzStringTest.ring, block #981.
#ERR exit 3221225794

load "../../stzBase.ring"

pr()

# Constarints are defined at the global level and then reused every where
# inside your softanza objects

DefineConstraints([
	:OnStzString = [
		:MustBeUppercase 	= '{ Q(@str).IsUppercase() }',
		:MustNotExceed@n@Chars 	= '{ Q(@str).NumberOfChars() <= n }',
		:MustBeginWithLetter@c@	= '{ Q(@str).BeginsWithCS(c, :CS = FALSE) }'
	],

	:OnStzNumber = [
		:MustBeStrictlyPositive = '{ @number > 0 }'
	],

	:OnStzList = [
		:MustBeAHashList = '{ Q(@list).IsHashList() }'
	]

])

# Let's use the constraints defined in a StzString object

StzStringQ("SOFTANZA") {

	EnforeConstraints([
		:MustBeUppercase,
		:MustNotExceed10Chars
	])

	? "Passed"
}

pf()
