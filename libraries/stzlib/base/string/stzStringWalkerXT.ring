#--------------------------------------------------------------#
#       SOFTANZA LIBRARY (V0.9) - STZSTRINGWALKERXT            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Extended string walker -- adds all          #
#                  Softanza method aliases to stzStringWalker   #
#                  via addmethod() for full fluency.            #
#                  Use stzStringWalker for lean canonical API.  #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringWalkerXT from stzStringWalker

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

			# --- Walker aliases ---

			[ "WalkerPositions",            "Walker" ],
			[ "WalkedPositionsBy",          "Walker" ],

			# --- CharAt aliases ---

			[ "NthChar",                    "CharAt" ],
			[ "Char",                       "CharAt" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
