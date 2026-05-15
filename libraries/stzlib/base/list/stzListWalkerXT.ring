#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTWALKERXT            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List walker extended class -- aliases       #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListWalkerXT from stzListWalker

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [

				# WalkNForward aliases
				[:WalkForwardNSteps,	:WalkNForward],
				[:WalkForward,		:WalkNForward],

				# WalkNBackward aliases
				[:WalkBackwardNSteps,	:WalkNBackward],
				[:WalkBackward,		:WalkNBackward],

				# WalkW aliases
				[:WalkWhere,		:WalkW],

				# WalkForthAndBack aliases
				[:WalkBackAndForth,	:WalkForthAndBack]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next

		ok
