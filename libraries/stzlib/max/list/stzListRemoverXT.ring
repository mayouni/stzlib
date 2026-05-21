#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTREMOVERXT           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List remover extended class -- aliases      #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListRemoverXT from stzListRemover

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [

				# RemoveAll aliases
				[:RemoveAllOccurrencesCS,	:RemoveAllCS],
				[:RemoveAllOccurrences,		:RemoveAll],
				[:RemoveItemCS,			:RemoveAllCS],
				[:RemoveItem,			:RemoveAll],

				# RemoveItemAtPosition aliases
				[:RemoveItemAt,			:RemoveItemAtPosition],

				# RemoveFirstItem misspelled
				[:RemoveFristItem,		:RemoveFirstItem],
				[:FristItemRemoved,		:FirstItemRemoved],

				# RemoveItemsAtPositions aliases
				[:RemoveAtPositions,		:RemoveItemsAtPositions],
				[:RemoveManyAtPositions,	:RemoveItemsAtPositions],

				# RemoveAllItems aliases
				[:Empty,			:RemoveAllItems],
				[:Flush,			:RemoveAllItems],

				# RemoveNthOccurrence aliases
				[:RemoveNthCS,			:RemoveNthOccurrenceCS],
				[:RemoveNth,			:RemoveNthOccurrence],

				# RemoveFirstOccurrence aliases
				[:RemoveFirstOccCS,		:RemoveFirstOccurrenceCS],
				[:RemoveFirstOcc,		:RemoveFirstOccurrence],

				# RemoveLastOccurrence aliases
				[:RemoveLastOccCS,		:RemoveLastOccurrenceCS],
				[:RemoveLastOcc,		:RemoveLastOccurrence]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next

		ok
