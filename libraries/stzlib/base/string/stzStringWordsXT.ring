#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGWORDSXT            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String words extended class -- aliases      #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringWordsXT from stzStringWords

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

			# --- Word list aliases ---

			[ "Words",		"AllWords" ],
			[ "NumberOfWords",	"WordCount" ],

			# --- Positional word aliases ---

			[ "FirstWord",		"TheFirstWord" ],
			[ "LastWord",		"TheLastWord" ],
			[ "NFirstWords",	"FirstNWords" ],
			[ "NLastWords",		"LastNWords" ],

			# --- Unique/Distinct aliases ---

			[ "UniqueWords",	"DistinctWords" ],

			# --- Extremes aliases ---

			[ "LongestWord",	"TheLongestWord" ],
			[ "ShortestWord",	"TheShortestWord" ],

			# --- Statistics aliases ---

			[ "AverageWordLength",	"MeanWordLength" ],
			[ "WordFrequencies",	"WordCounts" ],
			[ "MostFrequentWord",	"TopWord" ],

			# --- Contains aliases ---

			[ "ContainsWord",	"HasWord" ],

			# --- Replace word aliases ---

			[ "ReplaceWord",	"ChangeWord" ],
			[ "ReplaceWordQ",	"ChangeWordQ" ],
			[ "ReplaceWordCS",	"ChangeWordCS" ],
			[ "ReplaceWordCSQ",	"ChangeWordCSQ" ],

			# --- Remove word aliases ---

			[ "RemoveWord",		"DeleteWord" ],
			[ "RemoveWordQ",	"DeleteWordQ" ],
			[ "RemoveWordCS",	"DeleteWordCS" ],
			[ "RemoveWordCSQ",	"DeleteWordCSQ" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
