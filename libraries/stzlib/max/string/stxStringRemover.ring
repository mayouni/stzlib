#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STXSTRINGREMOVER          #
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

class stxStringRemover from stzStringRemover

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

			# --- Remove / Erase aliases ---

			[ "Erase",			"Remove" ],
			[ "EraseCS",			"RemoveCS" ],
			[ "EraseAll",			"RemoveAll" ],
			[ "EraseAllCS",			"RemoveAllCS" ],

			# --- RemoveFirst / RemoveLast aliases ---

			[ "EraseFirst",			"RemoveFirst" ],
			[ "EraseFirstCS",		"RemoveFirstCS" ],
			[ "EraseLast",			"RemoveLast" ],
			[ "EraseLastCS",		"RemoveLastCS" ],

			# --- RemoveNth aliases ---

			[ "EraseNth",			"RemoveNth" ],
			[ "EraseNthCS",			"RemoveNthCS" ],

			# --- RemoveSection / Range aliases ---

			[ "EraseSection",		"RemoveSection" ],
			[ "EraseRange",			"RemoveRange" ],

			# --- RemoveMany aliases ---

			[ "EraseMany",			"RemoveMany" ],
			[ "EraseManyCS",		"RemoveManyCS" ],
			[ "EraseThese",			"RemoveThese" ],
			[ "EraseTheseCS",		"RemoveTheseCS" ],

			# --- Between aliases ---

			[ "EraseBetween",		"RemoveBetween" ],
			[ "EraseBetweenCS",		"RemoveBetweenCS" ],
			[ "EraseBetweenIB",		"RemoveBetweenIB" ],
			[ "EraseBetweenCSIB",		"RemoveBetweenCSIB" ],

			# --- Duplicates aliases ---

			[ "EraseDuplicates",		"RemoveDuplicates" ],
			[ "EraseDuplicatesCS",		"RemoveDuplicatesCS" ],

			# --- FromLeft / FromRight aliases ---

			[ "EraseFromLeft",		"RemoveFromLeft" ],
			[ "EraseFromLeftCS",		"RemoveFromLeftCS" ],
			[ "EraseFromRight",		"RemoveFromRight" ],
			[ "EraseFromRightCS",		"RemoveFromRightCS" ],

			# --- Spaces aliases ---

			[ "EraseSpaces",		"RemoveSpaces" ],
			[ "EraseLeadingSpaces",		"RemoveLeadingSpaces" ],
			[ "EraseTrailingSpaces",	"RemoveTrailingSpaces" ],

			# --- Char at position aliases ---

			[ "EraseCharAt",		"RemoveCharAt" ],
			[ "EraseCharsAtPositions",	"RemoveCharsAtPositions" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
