#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STXSTRINGLEADTRAIL        #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String lead/trail extended class -- aliases #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stxStringLeadTrail from stzStringLeadTrail

	_bAliasesLoaded = FALSE

	def init(pcStr)
		super.init(pcStr)
		This._RegisterAliases()

	def _RegisterAliases()

		if _bAliasesLoaded
			return
		ok

		_bAliasesLoaded = TRUE

		_aAliases_ = [

			# --- Leading aliases ---

			[ "HasLeadingChars",		"HasRepeatedLeadingChars" ],
			[ "LeadingChars",		"RepeatedLeadingChars" ],
			[ "FirstChar",			"LeadingChar" ],

			# --- Trailing aliases ---

			[ "HasTrailingChars",		"HasRepeatedTrailingChars" ],
			[ "TrailingChars",		"RepeatedTrailingChars" ],
			[ "LastChar",			"TrailingChar" ],

			# --- Remove leading/trailing aliases ---

			[ "StripLeading",		"RemoveThisLeadingChar" ],
			[ "StripLeadingCS",		"RemoveThisLeadingCharCS" ],
			[ "StripTrailing",		"RemoveThisTrailingChar" ],
			[ "StripTrailingCS",		"RemoveThisTrailingCharCS" ],

			# --- Start/End aliases ---

			[ "BeginsWithCS",		"StartsWithCS" ],
			[ "BeginsWith",			"StartsWith" ],
			[ "FinishesWithCS",		"EndsWithCS" ],
			[ "FinishesWith",		"EndsWith" ],
			[ "RemoveFromBeginningCS",	"RemoveFromStartCS" ],
			[ "RemoveFromBeginning",	"RemoveFromStart" ],
			[ "RemoveFromFinishCS",		"RemoveFromEndCS" ],
			[ "RemoveFromFinish",		"RemoveFromEnd" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
