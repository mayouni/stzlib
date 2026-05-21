#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTREPLACERXT          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List replacer extended class -- aliases     #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListReplacerXT from stzListReplacer

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [

				# ReplaceAllOccurrences aliases
				[:ReplaceItemCS,		:ReplaceAllOccurrencesCS],
				[:ReplaceItem,			:ReplaceAllOccurrences],
				[:ReplaceEachItem,		:ReplaceAllItems],
				[:ReplaceEachItemWith,		:ReplaceAllItems],
				[:ReplaceAllItemsWith,		:ReplaceAllItems],

				# ReplaceNthOccurrence aliases
				[:ReplaceNthCS,			:ReplaceNthOccurrenceCS],
				[:ReplaceNth,			:ReplaceNthOccurrence],

				# ReplaceFirstOccurrence aliases
				[:ReplaceFirstCS,		:ReplaceFirstOccurrenceCS],
				[:ReplaceFirst,			:ReplaceFirstOccurrence],

				# ReplaceLastOccurrence aliases
				[:ReplaceLastCS,		:ReplaceLastOccurrenceCS],
				[:ReplaceLast,			:ReplaceLastOccurrence],

				# ReplaceAnyItemAtPosition aliases
				[:ReplaceItemAtPositionCS,	:ReplaceAnyItemAtPositionCS],
				[:ReplaceItemAtPosition,	:ReplaceAnyItemAtPosition],
				[:ReplaceAtCS,			:ReplaceAnyItemAtPositionCS],
				[:ReplaceAtPosition,		:ReplaceAnyItemAtPosition]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next

		ok
