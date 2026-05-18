#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STXSTRINGEXTRACTOR        #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String extractor extended class -- aliases  #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stxStringExtractor from stzStringExtractor

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

			# --- ExtractSection aliases ---

			[ "PopSection",		"ExtractSection" ],

			# --- ExtractRange aliases ---

			[ "PopRange",		"ExtractRange" ],

			# --- Extract aliases ---

			[ "ExtractAllOccurrences",	"Extract" ],
			[ "ExtractAllOccurrencesCS",	"ExtractCS" ],

			# --- ExtractMany aliases ---

			[ "ExtractSeveral",	"ExtractMany" ],
			[ "ExtractSeveralCS",	"ExtractManyCS" ],

			# --- ExtractAll aliases ---

			[ "PopAll",		"ExtractAll" ],
			[ "Drain",		"ExtractAll" ],

			# --- ExtractAt aliases ---

			[ "PopAt",		"ExtractAt" ],
			[ "PopCharAt",		"ExtractCharAt" ],

			# --- ExtractFirstChar aliases ---

			[ "PopFirstChar",	"ExtractFirstChar" ],

			# --- ExtractLastChar aliases ---

			[ "PopLastChar",	"ExtractLastChar" ],

			# --- ExtractFirst aliases ---

			[ "PopFirst",		"ExtractFirst" ],
			[ "PopFirstCS",		"ExtractFirstCS" ],

			# --- ExtractLast aliases ---

			[ "PopLast",		"ExtractLast" ],
			[ "PopLastCS",		"ExtractLastCS" ],

			# --- ExtractNthOccurrence aliases ---

			[ "PopNth",		"ExtractNthOccurrence" ],
			[ "PopNthCS",		"ExtractNthOccurrenceCS" ],

			# --- ExtractCharsW aliases ---

			[ "PopCharsW",		"ExtractCharsW" ],
			[ "PopCharsWCS",	"ExtractCharsWCS" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
