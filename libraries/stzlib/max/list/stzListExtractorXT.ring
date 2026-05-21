#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTEXTRACTORXT         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List extractor extended class -- aliases   #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListExtractorXT from stzListExtractor

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [
				[:PopCS,		:ExtractCS],
				[:PopMany,		:ExtractMany],
				[:PopManyCS,		:ExtractManyCS],
				[:PopAll,		:ExtractAll],
				[:Drain,		:ExtractAll],
				[:PopNth,		:ExtractNth],
				[:PopSection,		:ExtractSection],
				[:PopRange,		:ExtractRange],
				[:PopW,			:ExtractW],
				[:PopNthOccurrence,	:ExtractNthOccurrence],
				[:PopNthOccurrenceCS,	:ExtractNthOccurrenceCS],
				[:PopFirstOccurrence,	:ExtractFirstOccurrence],
				[:PopLastOccurrence,	:ExtractLastOccurrence],
				[:PopDuplicates,	:ExtractDuplicates],
				[:PopDuplicatesCS,	:ExtractDuplicatesCS],
				[:PopStrings,		:ExtractStrings],
				[:PopNumbers,		:ExtractNumbers],
				[:PopLists,		:ExtractLists],
				[:TakeFirst,		:Take],
				[:TakeFromStart,	:Take],
				[:TakeFromEnd,		:TakeLast]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next
		ok
