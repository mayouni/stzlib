#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTSPLITSXT            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List splits extended class -- aliases       #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListSplitsXT from stzListSplits

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [

				# SplitAt aliases
				[:SplitAtItem,			:SplitAt],
				[:SplitAtThisItem,		:SplitAt],

				# SplitBefore aliases
				[:SplitBeforeItem,		:SplitBefore],
				[:SplitBeforeThisItem,		:SplitBefore],

				# SplitAfter aliases
				[:SplitAfterItem,		:SplitAfter],
				[:SplitAfterThisItem,		:SplitAfter],

				# SplitToNParts aliases
				[:SplitIntoNParts,		:SplitToNParts],

				# SplitToPartsOfNItems aliases
				[:SplitIntoPartsOfNItems,	:SplitToPartsOfNItems],
				[:SplitIntoPartsOf,		:SplitToPartsOfNItems],

				# SplitW aliases
				[:SplitWhere,			:SplitW],

				# Passive form aliases
				[:SplittedAtItem,		:SplittedAt],
				[:SplittedBeforeItem,		:SplittedBefore],
				[:SplittedAfterItem,		:SplittedAfter]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next
		ok
