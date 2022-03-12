load "stzlib.ring"

o1 = new stzString("+12500.99")
? o1.RepresentsNumberInDecimalForm()

/*
	Test these (and then --> ensure they also exist for stzList):

	def ContainsCS(cSubStr, aCaseSensitive) # :CaseSensitive = TRUE or :CaseSensitive = FALSE
	def Contains(cSubStr)
	def ContainsNo(cSubStr)
	def ContainsNoDigits()
	def ContainsEachCS(paSubStr, pcCaseSensitive)
	def ContainsEach(paSubStr)
	def ContainsNoOne(paSubStr)
	def ContainsNoOneCS(paSubStr, pCaseSensitive)
	def ContainsNTimesTheSubstringCS(n, pcSubstr,  pCaseSensitive)
	def ContainsNTimes(n, pcSubStr)
*/
