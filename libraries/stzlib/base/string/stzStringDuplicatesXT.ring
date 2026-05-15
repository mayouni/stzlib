#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V0.9) - STZSTRINGDUPLICATESXT         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String duplicates extended class -- aliases #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringDuplicatesXT from stzStringDuplicates

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

			# --- Duplicate chars aliases ---

			[ "DuplicatedChars",			"DuplicateChars" ],
			[ "HasDuplicatedChars",			"HasDuplicates" ],

			# --- Consecutive dedup aliases ---

			[ "RemoveConsecutiveDuplicateChars",	"DeduplicateChars" ],
			[ "RemoveConsecutiveDuplicateCharsQ",	"DeduplicateCharsQ" ],
			[ "ConsecutiveDuplicateCharsRemoved",	"CharsDedup" ],

			# --- Count aliases ---

			[ "NumberOfDuplicatedChars",		"CountDuplicatedChars" ],

			# --- Unique aliases ---

			[ "UniqueChars",			"DistinctChars" ],
			[ "NumberOfUniqueChars",		"CountUniqueChars" ],

			# --- Consecutive duplicates aliases ---

			[ "HasConsecutiveDuplicates",		"HasConsecutiveDups" ],

			# --- Full dedup aliases ---

			[ "RemoveAllDuplicateChars",		"Deduplicate" ],
			[ "RemoveAllDuplicateCharsQ",		"DeduplicateQ" ],
			[ "AllDuplicateCharsRemoved",		"Deduplicated" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
