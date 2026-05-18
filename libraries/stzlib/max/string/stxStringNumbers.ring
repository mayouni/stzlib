#--------------------------------------------------------------#
#       SOFTANZA LIBRARY (V0.9) - STXSTRINGNUMBERS           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String numbers extended class -- aliases    #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stxStringNumbers from stzStringNumbers

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

			# --- Numbers aliases ---

			[ "FindNumbers",		"Numbers" ],
			[ "AllNumbers",			"Numbers" ],

			# --- NumberOfNumbers aliases ---

			[ "HowManyNumbers",		"NumberOfNumbers" ],

			# --- MaxNumber / MinNumber aliases ---

			[ "BiggestNumber",		"MaxNumber" ],
			[ "SmallestNumber",		"MinNumber" ],

			# --- AverageOfNumbers aliases ---

			[ "MeanOfNumbers",		"AverageOfNumbers" ],

			# --- FirstNumber / LastNumber aliases ---

			[ "TheFirstNumber",		"FirstNumber" ],
			[ "TheLastNumber",		"LastNumber" ],

			# --- RemoveNumbers aliases ---

			[ "ClearNumbers",		"RemoveNumbers" ],
			[ "ClearNumbersQ",		"RemoveNumbersQ" ],
			[ "NumbersCleared",		"NumbersRemoved" ],

			# --- ReplaceNumbers aliases ---

			[ "ChangeNumbers",		"ReplaceNumbers" ],
			[ "ChangeNumbersQ",		"ReplaceNumbersQ" ],
			[ "NumbersChanged",		"NumbersReplaced" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
