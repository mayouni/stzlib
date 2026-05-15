#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTDUPLICATESXT        #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List duplicates extended class -- aliases   #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListDuplicatesXT from stzListDuplicates

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [

				# FindDuplicates aliases
				[:DuplicatePositionsCS,		:FindDuplicatesCS],
				[:DuplicatePositions,		:FindDuplicates],

				# RemoveDuplicates aliases
				[:RemoveDupsCS,			:RemoveDuplicatesCS],
				[:RemoveDups,			:RemoveDuplicates],
				[:DropDuplicatesCS,		:RemoveDuplicatesCS],
				[:DropDuplicates,		:RemoveDuplicates],

				# WithoutDuplication aliases
				[:WithoutDupsCS,		:WithoutDuplicationCS],
				[:WithoutDups,			:WithoutDuplication],

				# HasDuplicates aliases
				[:ContainsDuplicatesCS,		:HasDuplicatesCS],

				# UniqueItems aliases
				[:DistinctCS,			:UniqueItemsCS],
				[:Distinct,			:UniqueItems],
				[:DistinctItemsCS,		:UniqueItemsCS],
				[:DistinctItems,		:UniqueItems]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next

		ok
