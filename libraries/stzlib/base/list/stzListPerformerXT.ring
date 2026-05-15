#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTPERFORMERXT         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List performer extended class -- aliases   #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListPerformerXT from stzListPerformer

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [
				[:PerformOnEach,	:Perform],
				[:PerformOnPositions,	:PerformOn],
				[:ForEach,		:Perform],
				[:ForEachQ,		:PerformQ],
				[:ForEachOn,		:PerformOn],
				[:ForEachW,		:PerformW],
				[:Harvest,		:Yield],
				[:Collect,		:Yield],
				[:HarvestOn,		:YieldOn],
				[:CollectOn,		:YieldOn],
				[:HarvestW,		:YieldW],
				[:CollectW,		:YieldW],
				[:CollectPairs,		:YieldPairs],
				[:HarvestPairs,		:YieldPairs]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next
		ok
