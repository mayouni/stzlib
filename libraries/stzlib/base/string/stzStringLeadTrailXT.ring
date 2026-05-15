#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGLEADTRAILXT        #
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

class stzStringLeadTrailXT from stzStringLeadTrail

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

			# --- HasRepeatedLeadingChars aliases ---

			[ "HasLeadingChars",		"HasRepeatedLeadingChars" ],

			# --- HasRepeatedTrailingChars aliases ---

			[ "HasTrailingChars",		"HasRepeatedTrailingChars" ],

			# --- RepeatedLeadingChars aliases ---

			[ "LeadingChars",		"RepeatedLeadingChars" ],

			# --- RepeatedTrailingChars aliases ---

			[ "TrailingChars",		"RepeatedTrailingChars" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
