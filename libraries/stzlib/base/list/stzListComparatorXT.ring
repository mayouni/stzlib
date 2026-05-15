#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTCOMPARATORXT        #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List comparator extended class -- aliases  #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListComparatorXT from stzListComparator

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [
				[:IntersectionCS,	:CommonItemsCS],
				[:Intersection,		:CommonItems],
				[:SharedItemsCS,	:CommonItemsCS],
				[:SharedItems,		:CommonItems],
				[:Diff,			:Difference],
				[:DiffCS,		:DifferenceCS],
				[:IsTheSameAs,		:IsEqualTo],
				[:IsTheSameAsCS,	:IsEqualToCS],
				[:IsDifferentFrom,	:IsNotEqualTo],
				[:IsDifferentFromCS,	:IsNotEqualToCS],
				[:SymDiff,		:SymmetricDifference],
				[:SymDiffCS,		:SymmetricDifferenceCS],
				[:Includes,		:Contains],
				[:IncludesCS,		:ContainsCS],
				[:IncludesAll,		:ContainsAllOfThese],
				[:IncludesAllCS,	:ContainsAllOfTheseCS],
				[:IncludesOne,		:ContainsOneOfThese],
				[:IncludesOneCS,	:ContainsOneOfTheseCS]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next
		ok
