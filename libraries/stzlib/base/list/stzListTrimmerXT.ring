#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTTRIMMERXT           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List trimmer extended class -- aliases     #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListTrimmerXT from stzListTrimmer

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [
				[:TrimStart,		:TrimLeft],
				[:TrimEnd,		:TrimRight],
				[:Strip,		:Trim],
				[:StripQ,		:TrimQ],
				[:StripLeft,		:TrimLeft],
				[:StripRight,		:TrimRight],
				[:StripItem,		:TrimItem],
				[:StripItemCS,		:TrimItemCS],
				[:StripItemFromLeft,	:TrimItemFromLeft],
				[:StripItemFromLeftCS,	:TrimItemFromLeftCS],
				[:StripItemFromRight,	:TrimItemFromRight],
				[:StripItemFromRightCS,	:TrimItemFromRightCS],

				# Compact aliases
				[:RemoveEmpty,		:Compact],
				[:RemoveEmpties,	:Compact],
				[:WithoutEmpty,		:Compacted],
				[:WithoutEmpties,	:Compacted],

				# Squeeze aliases
				[:SqueezeEmpty,		:Squeeze],
				[:Condensed,		:Squeezed],
				[:Condense,		:Squeeze],

				# StripNulls aliases
				[:RemoveNulls,		:StripNulls],
				[:WithoutNulls,		:NullsStripped],

				# TrimToSize aliases
				[:Truncate,		:TrimToSize],
				[:Truncated,		:TrimmedToSize],
				[:LimitTo,		:TrimToSize],

				# TrimW aliases
				[:TrimWhere,		:TrimW],
				[:TrimmedWhere,		:TrimmedW],
				[:RemoveWhere,		:TrimW],
				[:RemovedW,		:TrimmedW]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next
		ok
