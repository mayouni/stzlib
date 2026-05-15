#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGREMOVERXT          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String remover extended class -- aliases    #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringRemoverXT from stzStringRemover

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

			# --- Remove aliases ---

			[ "Erase",		"Remove" ],
			[ "EraseCS",		"RemoveCS" ],

			# --- RemoveFirst aliases ---

			[ "EraseFirst",		"RemoveFirst" ],

			# --- RemoveLast aliases ---

			[ "EraseLast",		"RemoveLast" ],

			# --- RemoveNth aliases ---

			[ "EraseNth",		"RemoveNth" ],

			# --- RemoveSection aliases ---

			[ "EraseSection",	"RemoveSection" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
