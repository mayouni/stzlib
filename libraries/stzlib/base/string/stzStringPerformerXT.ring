#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGPERFORMERXT        #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String performer extended class -- aliases  #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringPerformerXT from stzStringPerformer

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

			# --- Perform aliases ---

			[ "ForEach",		"Perform" ],
			[ "ForEachQ",		"PerformQ" ],

			# --- PerformOn aliases ---

			[ "ForEachOn",		"PerformOn" ],
			[ "ForEachOnQ",		"PerformOnQ" ],

			# --- PerformW aliases ---

			[ "ForEachW",		"PerformW" ],
			[ "ForEachWQ",		"PerformWQ" ],

			# --- Yield aliases ---

			[ "Harvest",		"Yield" ],
			[ "Collect",		"Yield" ],

			# --- YieldOn aliases ---

			[ "HarvestOn",		"YieldOn" ],
			[ "CollectOn",		"YieldOn" ],

			# --- YieldW aliases ---

			[ "HarvestW",		"YieldW" ],
			[ "CollectW",		"YieldW" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
