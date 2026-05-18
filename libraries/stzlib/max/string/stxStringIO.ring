#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STXSTRINGIO             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String I/O extended class -- aliases        #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stxStringIO from stzStringIO

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

			# --- File read aliases ---

			[ "FromFile",		"ReadFromFile" ],
			[ "FromFileQ",		"ReadFromFileQ" ],

			# --- File write aliases ---

			[ "ToFile",		"WriteToFile" ],
			[ "ToFile",		"SaveAs" ],
			[ "ToFile",		"ExportAs" ],

			# --- File append/prepend aliases ---

			[ "AppendToFile",	"AddToFile" ],
			[ "PrependToFile",	"InsertBeforeFile" ],

			# --- URL/Email validation aliases ---

			[ "IsURL",		"IsValidURL" ],
			[ "IsEmail",		"IsEmailAddress" ],
			[ "IsEmail",		"IsValidEmail" ],

			# --- Format conversion aliases ---

			[ "ToJSON",		"AsJSON" ],
			[ "ToCSV",		"AsCSV" ],
			[ "ToXML",		"AsXML" ],
			[ "ToHTML",		"AsHTML" ],

			# --- Encoding aliases ---

			[ "IsBase64",		"IsBase64Encoded" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
