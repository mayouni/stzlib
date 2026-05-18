#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STXSTRINGCODE           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String code extended class -- aliases       #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stxStringCode from stzStringCode

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

			# --- Run aliases ---

			[ "Execute",		"RunCode" ],
			[ "ExecuteAndReturn",	"RunAndReturn" ],

			# --- Contains aliases ---

			[ "ContainsFunctions",	"HasFunctions" ],
			[ "ContainsClasses",	"HasClasses" ],

			# --- Count aliases ---

			[ "NumberOfFunctions",	"CountFunctions" ],
			[ "NumberOfClasses",	"CountClasses" ],

			# --- Extract aliases ---

			[ "FunctionNames",	"ExtractFunctionNames" ],
			[ "ClassNames",		"ExtractClassNames" ],

			# --- Line aliases ---

			[ "IsBlankLine",	"IsBlank" ],
			[ "LinesOfCode",	"CountLinesOfCode" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
