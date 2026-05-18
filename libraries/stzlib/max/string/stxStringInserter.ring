#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STXSTRINGINSERTER         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String inserter extended class -- aliases   #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stxStringInserter from stzStringInserter

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

			# --- Position aliases ---

			[ "InsertAt",				"InsertBefore" ],
			[ "InsertAtQ",				"InsertBeforeQ" ],
			[ "InsertAtPosition",			"InsertBefore" ],
			[ "InsertAfterPosition",		"InsertAfter" ],

			# --- SubString aliases ---

			[ "InsertBeforeEachCS",			"InsertBeforeSubStringCS" ],
			[ "InsertAfterEachCS",			"InsertAfterSubStringCS" ],
			[ "InsertBeforeEach",			"InsertBeforeSubString" ],
			[ "InsertAfterEach",			"InsertAfterSubString" ],

			# --- Nth occurrence aliases ---

			[ "InsertAfterNthOccurrenceCS",		"InsertAfterNthCS" ],
			[ "InsertAfterNthOccurrence",		"InsertAfterNth" ],
			[ "InsertBeforeNthOccurrenceCS",	"InsertBeforeNthCS" ],
			[ "InsertBeforeNthOccurrence",		"InsertBeforeNth" ],

			# --- First/Last occurrence aliases ---

			[ "InsertAfterFirstOccurrenceCS",	"InsertAfterFirstCS" ],
			[ "InsertAfterFirstOccurrence",		"InsertAfterFirst" ],
			[ "InsertAfterLastOccurrenceCS",	"InsertAfterLastCS" ],
			[ "InsertAfterLastOccurrence",		"InsertAfterLast" ],
			[ "InsertBeforeFirstOccurrenceCS",	"InsertBeforeFirstCS" ],
			[ "InsertBeforeFirstOccurrence",	"InsertBeforeFirst" ],
			[ "InsertBeforeLastOccurrenceCS",	"InsertBeforeLastCS" ],
			[ "InsertBeforeLastOccurrence",		"InsertBeforeLast" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
