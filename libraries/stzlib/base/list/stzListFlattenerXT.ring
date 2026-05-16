#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTFLATTENERXT         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List flattener extended class -- aliases    #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListFlattenerXT from stzListFlattener

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [

				# Associate aliases
				[:Associate,		:AssociateWith],
				[:AssociateQ,		:AssociateWithQ],
				[:Associated,		:AssociatedWith],

				# Leading/Trailing aliases
				[:HasLeadingRepeatedItemsCS,	:HasRepeatedLeadingItemsCS],
				[:HasLeadingItemsCS,		:HasRepeatedLeadingItemsCS],
				[:ContainsRepeatedLeadingItemsCS,	:HasRepeatedLeadingItemsCS],
				[:ContainsLeadingRepeatedItemsCS,	:HasRepeatedLeadingItemsCS],
				[:ContainsLeadingItemsCS,		:HasRepeatedLeadingItemsCS],
				[:HasLeadingRepeatedItems,		:HasRepeatedLeadingItemsCS],
				[:ContainsRepeatedLeadingItems,		:HasRepeatedLeadingItemsCS],

				# Stringify aliases
				[:StringifyList,	:Stringify],

				# DeepFlatten aliases
				[:DeepFlat,		:DeepFlatten],
				[:FullyFlattened,	:DeepFlattened],
				[:FullyFlatten,		:DeepFlatten],

				# FlattenToDepth aliases
				[:FlattenDepth,		:FlattenToDepth],
				[:FlattenLevel,		:FlattenToDepth],
				[:FlattenedDepth,	:FlattenedToDepth],
				[:FlattenedLevel,	:FlattenedToDepth],

				# Paired aliases
				[:AsPairs,		:Paired],
				[:ToPairs,		:Paired],
				[:GroupedInPairs,	:Paired],

				# Chunked aliases
				[:GroupedInto,		:Chunked],
				[:SplitInto,		:Chunked],
				[:InGroupsOf,		:Chunked],

				# Interleave aliases
				[:MergedWith,		:InterleavedWith],
				[:InterlacedWith,	:InterleavedWith],
				[:ZippedWith,		:InterleavedWith]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next

		ok
