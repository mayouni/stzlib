#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGINSERTERXT         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String inserter extended class -- aliases   #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringInserterXT from stzStringInserter

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

			# --- InsertBefore aliases ---

			[ "InsertAt",			"InsertBefore" ],
			[ "InsertAtQ",			"InsertBeforeQ" ],

			# --- InsertBeforeSubStringCS aliases ---

			[ "InsertBeforeEachCS",		"InsertBeforeSubStringCS" ],

			# --- InsertAfterSubStringCS aliases ---

			[ "InsertAfterEachCS",		"InsertAfterSubStringCS" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
