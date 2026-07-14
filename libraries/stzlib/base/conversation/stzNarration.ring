# R3b -- stzNarration: THE SYSTEM'S SIDE OF THE DIALOGUE
# The narration culture (Why-chains, evidentiality, prose) promoted
# from a habit into a construct: an ordered, speaker-tagged transcript
# the conversation writes as it thinks.
#
#   oN = new stzNarration()
#   oN.System("What does 'margherita' contain?")
#   oN.User("tomato-sauce")
#   oN.Verdict("yes: 'margherita' contains 'tomato-sauce'", 1)
#   ? oN.Text()

class stzNarration from stzObject

	@aLines = []    # [ [ speaker, text, certainty ] ... ]

	def init()

	def System(pcText)
		@aLines + [ "system", "" + pcText, 1 ]
		return This

	def User(pcText)
		@aLines + [ "user", "" + pcText, 1 ]
		return This

	# a verdict line carries its evidential certainty (1 when the
	# admission was deterministic -- the R1 register)
	def Verdict(pcText, pnCertainty)
		@aLines + [ "verdict", "" + pcText, pnCertainty ]
		return This

	def Lines()
		return @aLines

	def NumberOfLines()
		return len(@aLines)

	def Text()
		_c_ = ""
		_n_ = len(@aLines)
		for _i_ = 1 to _n_
			_cTag_ = @aLines[_i_][1]
			if _cTag_ = "system"
				_c_ += "SOFTANZA: " + @aLines[_i_][2] + NL
			but _cTag_ = "user"
				_c_ += "YOU:      " + @aLines[_i_][2] + NL
			else
				_c_ += "  -> " + @aLines[_i_][2] + NL
			ok
		next
		return _c_
