#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTBOUNDERXT           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List bounder extended class -- aliases      #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListBounderXT from stzListBounder

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [

				# Section aliases
				[:SliceCS,		:SectionCS],
				[:SliceCSQ,		:SectionCSQ],
				[:Slice,		:Section],
				[:SliceQ,		:SectionQ],

				# Sections aliases
				[:ManySections,		:Sections],

				# AreBoundsOf aliases
				[:AreBoundsOfCSXT,	:AreBoundsOfCS],
				[:AreBoundsOfXT,	:AreBoundsOf],

				# Bounds aliases
				[:ListBounds,		:Bounds],

				# RemoveBounds aliases
				[:UnBound,		:RemoveBounds],
				[:Unbounded,		:BoundsRemoved],

				# Middle aliases
				[:WithoutBounds,	:Middle],
				[:InnerItems,		:Middle],
				[:Core,			:Middle],

				# Range aliases
				[:SubRange,		:Range],
				[:ItemsFromFor,		:Range],

				# ClampedTo aliases
				[:Clamped,		:ClampedTo],
				[:BoundedTo,		:ClampedTo],
				[:ConstrainedTo,	:ClampedTo],

				# IsWithinBounds aliases
				[:PositionExists,	:IsWithinBounds],
				[:HasPosition,		:IsWithinBounds],
				[:InBounds,		:IsWithinBounds],

				# NFirstItems aliases
				[:FirstNItems,		:NFirstItems],
				[:Take,			:NFirstItems],
				[:Head,			:NFirstItems],

				# NLastItems aliases
				[:LastNItems,		:NLastItems],
				[:TakeLast,		:NLastItems],
				[:Tail,			:NLastItems],

				# ItemsBetweenPositions aliases
				[:Between,		:ItemsBetweenPositions],
				[:From_To,		:ItemsBetweenPositions]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next

		ok
