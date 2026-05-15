#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGTRIMMERXT          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String trimmer extended class -- aliases    #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringTrimmerXT from stzStringTrimmer

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

			# --- Trim aliases ---

			[ "Strip",		"Trim" ],

			# --- TrimLeft aliases ---

			[ "StripLeft",		"TrimLeft" ],

			# --- TrimRight aliases ---

			[ "StripRight",		"TrimRight" ],

			# --- TrimStart aliases ---

			[ "StripStart",		"TrimStart" ],

			# --- TrimEnd aliases ---

			[ "StripEnd",		"TrimEnd" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
