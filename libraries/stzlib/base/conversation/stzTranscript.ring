# R3b -- stzTranscript: THE SYSTEM'S SIDE OF THE DIALOGUE, AS A RECORD
# The narration culture (Why-chains, evidentiality, prose) promoted
# from a habit into a construct: an ordered, speaker-tagged transcript
# the conversation writes as it thinks.
#
# RENAMED from stzNarration on 2026-09-06 (reference design v1.2, the
# sibling's obligation O1): this class is a TRANSCRIPT, precisely -- lines
# with a speaker and a certainty -- and was never a document. The name
# stzNarration is the document class of the Narrations layer, and a
# visual narration (DN9) is told through stzStoryboard.
#
#   oN = new stzTranscript()
#   oN.System("What does 'margherita' contain?")
#   oN.User("tomato-sauce")
#   oN.Verdict("yes: 'margherita' contains 'tomato-sauce'", 1)
#   ? oN.Text()

# Records the dialogue a conversation holds as an ordered list of speaker-tagged lines, each with a certainty.
#
# The system speaks with System, the user with User, and a conclusion is added with Verdict, which
# carries its evidential certainty. Lines gives the rows back as data and Text renders them for a
# reader. It is a record, not a document: the document class of the narrations layer is another one.
#
#   receiver   o1 = new stzTranscript()
#   example    o1.System("What does margherita contain?")
#              o1.User("tomato-sauce")
#              o1.Verdict("yes: contains tomato-sauce", 1)
#              ? o1.NumberOfLines()
#              #--> 3
#              ? o1.Lines()[2][2]
#              #--> tomato-sauce
#   see        stzGoal, stzConversation, stzKnowledgeGraph
class stzTranscript from stzObject

	@aLines = []    # [ [ speaker, text, certainty ] ... ]

	# Builds an empty transcript with no line.
	#
	#   returns    nothing; the object is built
	#   see        System, User, Verdict
	def init()

	# Appends a line spoken by the system, kept as text with full certainty.
	#
	#   pcText     what the system says
	#   returns    the transcript itself, so calls chain
	#   see        User, Verdict, Text
	def System(pcText)
		@aLines + [ "system", "" + pcText, 1 ]
		return This

	# Appends a line spoken by the user, kept as text with full certainty.
	#
	#   pcText     what the user says
	#   returns    the transcript itself, so calls chain
	#   see        System, Verdict, Text
	def User(pcText)
		@aLines + [ "user", "" + pcText, 1 ]
		return This

	# Appends a conclusion line that carries how certain it is.
	#
	#   pcText        the conclusion
	#   pnCertainty   the evidential certainty, 1 when the admission was deterministic
	#   returns       the transcript itself, so calls chain
	#   warning       the certainty is kept in Lines and left out of Text; calling it with one
	#                 argument raises R19
	#   see           System, Lines, Text
	#@ aka  a verdict line carries its evidential certainty (1 when the admission was deterministic -- the R1 register)
	def Verdict(pcText, pnCertainty)
		@aLines + [ "verdict", "" + pcText, pnCertainty ]
		return This

	# Returns every line in order, as [ speaker, text, certainty ] rows.
	#
	#   returns    a list of three-item lists; the speaker is system, user or verdict
	#   see        NumberOfLines, Text
	def Lines()
		return @aLines

	# Returns how many lines the transcript holds.
	#
	#   returns    a number
	#   see        Lines
	def NumberOfLines()
		return len(@aLines)

	# Returns the transcript as a reading text: SOFTANZA and YOU prefixes for the two voices, an arrow for a verdict, one line each.
	#
	#   returns    a text, empty for an empty transcript
	#   see        Lines, System
	def Text()
		_c_ = ""
		_n_ = len(@aLines)
		for _i_ = 1 to _n_
			_cTag_ = @aLines[_i_][1]
			if _cTag_ = "system"
				_c_ += "SOFTANZA: " + @aLines[_i_][2] + char(10)
			but _cTag_ = "user"
				_c_ += "YOU:      " + @aLines[_i_][2] + char(10)
			else
				_c_ += "  -> " + @aLines[_i_][2] + char(10)
			ok
		next
		return _c_
