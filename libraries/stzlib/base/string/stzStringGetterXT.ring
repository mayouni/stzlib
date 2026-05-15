#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGGETTERXT           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String getter extended class -- aliases     #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringGetterXT from stzStringGetter

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

			# --- NthChar aliases ---

			[ "CharAt",		"NthChar" ],

			# --- FirstChar aliases ---

			[ "First",		"FirstChar" ],

			# --- LastChar aliases ---

			[ "Last",		"LastChar" ],

			# --- NFirstChars aliases ---

			[ "TopN",		"NFirstChars" ],

			# --- NLastChars aliases ---

			[ "BottomN",		"NLastChars" ],

			# --- MiddleChar aliases ---

			[ "Central",		"MiddleChar" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
