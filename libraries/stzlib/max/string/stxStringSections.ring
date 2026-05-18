#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STXSTRINGSECTIONS         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String sections extended class -- aliases   #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stxStringSections from stzStringSections

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

			# --- Section aliases ---

			[ "Slice",		"Section" ],
			[ "SliceCS",		"SectionCS" ],

			# --- Sections aliases ---

			[ "Slices",		"Sections" ],
			[ "ManySections",	"Sections" ],

			# --- SectionBetween aliases ---

			[ "SliceBetween",	"SectionBetween" ],

			# --- RemoveSection aliases ---

			[ "DeleteSection",	"RemoveSection" ],
			[ "DeleteSectionQ",	"RemoveSectionQ" ],
			[ "EraseSection",	"RemoveSection" ],

			# --- RemoveSections aliases ---

			[ "DeleteSections",	"RemoveSections" ],
			[ "DeleteSectionsQ",	"RemoveSectionsQ" ],
			[ "EraseSections",	"RemoveSections" ],

			# --- RemoveRange aliases ---

			[ "DeleteRange",	"RemoveRange" ],
			[ "DeleteRangeQ",	"RemoveRangeQ" ],
			[ "EraseRange",		"RemoveRange" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
