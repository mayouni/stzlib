#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V0.9) - STZSTRINGRANDOMIZERXT         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String randomizer extended class -- aliases #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringRandomizerXT from stzStringRandomizer

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

			# --- Scramble/Shuffle aliases ---

			[ "Shuffle",		"Scramble" ],
			[ "ShuffleQ",		"ScrambleQ" ],
			[ "Shuffled",		"Scrambled" ],

			# --- Random char aliases ---

			[ "RandomChar",		"ARandomChar" ],
			[ "RandomChars",	"SomeRandomChars" ],
			[ "NRandomChars",	"NRandomUniqueChars" ],

			# --- Random word aliases ---

			[ "RandomWord",		"ARandomWord" ],

			# --- Shuffle words aliases ---

			[ "ShuffleWords",	"ScrambleWords" ],
			[ "ShuffleWordsQ",	"ScrambleWordsQ" ],
			[ "WordsShuffled",	"WordsScrambled" ],

			# --- Random case aliases ---

			[ "RandomCase",		"RandomizeCase" ],
			[ "RandomCaseQ",	"RandomizeCaseQ" ],
			[ "RandomCased",	"CaseRandomized" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
