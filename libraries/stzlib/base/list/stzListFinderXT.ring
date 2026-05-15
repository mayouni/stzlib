#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTFINDERXT            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List finder extended class -- aliases       #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListFinderXT from stzListFinder

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [

				# FindAllOccurrences aliases
				[:FindItemCS,		:FindAllOccurrencesCS],
				[:PositionsCS,		:FindAllOccurrencesCS],
				[:OccurrencesCS,	:FindAllOccurrencesCS],
				[:FindItem,		:FindAllOccurrences],
				[:Positions,		:FindAllOccurrences],
				[:Occurrences,		:FindAllOccurrences],

				# FindNth aliases
				[:FindNthOccurrenceCS,	:FindNthCS],
				[:FindNthOccurrence,	:FindNth],

				# FindFirst/Last aliases
				[:FindFirstOccurrenceCS,	:FindFirstCS],
				[:FindFirstOccurrence,		:FindFirst],
				[:FindLastOccurrenceCS,		:FindLastCS],
				[:FindLastOccurrence,		:FindLast],

				# FindNext aliases
				[:FindNextCS,		:FindNextOccurrenceCS],
				[:FindNext,		:FindNextOccurrence],

				# FindPrevious aliases
				[:FindPreviousCS,	:FindPreviousOccurrenceCS],
				[:FindPrevious,		:FindPreviousOccurrence],

				# NumberOfOccurrence aliases
				[:NumberOfOccurrencesCS,	:NumberOfOccurrenceCS],
				[:NumberOfOccurrences,	:NumberOfOccurrence],
				[:CountCS,		:NumberOfOccurrenceCS],
				[:CountOf,		:NumberOfOccurrence],
				[:HowManyCS,		:NumberOfOccurrenceCS],

				# Contains aliases
				[:ContainsItemCS,	:ContainsCS],
				[:ContainsItem,		:Contains],
				[:IncludesCS,		:ContainsCS],
				[:Includes,		:Contains],

				# ContainsMany aliases
				[:ContainsAllCS,	:ContainsManyCS],
				[:ContainsAll,		:ContainsMany],
				[:IncludesAllCS,	:ContainsManyCS],
				[:IncludesAll,		:ContainsMany]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next

		ok
