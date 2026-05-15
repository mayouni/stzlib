#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTLEADTRAILXT         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List lead/trail extended class -- aliases  #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListLeadTrailXT from stzListLeadTrail

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [
				[:HasLeadingItems,	:HasRepeatedLeadingItems],
				[:HasTrailingItems,	:HasRepeatedTrailingItems],
				[:LeadingItems,		:RepeatedLeadingItems],
				[:TrailingItems,	:RepeatedTrailingItems],
				[:TrimRepeatedLeading,	:RemoveRepeatedLeadingItems],
				[:TrimRepeatedTrailing,	:RemoveRepeatedTrailingItems]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next
		ok
