#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTXT                  #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List extended class -- base-level aliases   #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListXT from stzList

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [

				# Content aliases
				[:Value,		:Content],
				[:ValueQ,		:ContentQ],
				[:List,			:Content],
				[:ListQ,		:ContentQ],
				[:TheList,		:Content],
				[:TheListQ,		:ContentQ],

				# Content CS aliases
				[:ValueCS,		:ContentCS],
				[:ValueCSQ,		:ContentCSQ],
				[:ListCS,		:ContentCS],
				[:ListCSQ,		:ContentCSQ],
				[:TheListCS,		:ContentCS],
				[:TheListCSQ,		:ContentCSQ],

				# Content U aliases
				[:ValueU,		:ContentU],
				[:ValueUQ,		:ContentUQ],
				[:ListU,		:ContentU],
				[:ListUQ,		:ContentUQ],
				[:ValueCSU,		:ContentCSU],
				[:ValueCSUQ,		:ContentCSUQ],
				[:ListCSU,		:ContentCSU],
				[:ListCSUQ,		:ContentCSUQ],

				# NumberOfItems aliases
				[:Size,			:NumberOfItems],
				[:SizeQ,		:NumberOfItemsQ],
				[:SizeB,		:NumberOfItemsB],
				[:Length,		:NumberOfItems],
				[:LengthQ,		:NumberOfItemsQ],
				[:LengthB,		:NumberOfItemsB],
				[:Count,		:NumberOfItems],
				[:HowMany,		:NumberOfItems],
				[:HowManyItems,		:NumberOfItems],
				[:HowManyItemsQ,	:NumberOfItemsQ],
				[:HowManyItemsB,	:NumberOfItemsB],
				[:CountItems,		:NumberOfItems],
				[:CountItemsQ,		:NumberOfItemsQ],
				[:CountItemsB,		:NumberOfItemsB],

				# NumberOfItems A-prefix (natural-coding)
				[:ANumberOfItems,	:NumberOfItems],
				[:ANumberOfItemsQ,	:NumberOfItemsQ],
				[:ANumberOfItemsB,	:NumberOfItemsB],
				[:ASize,		:NumberOfItems],
				[:ASizeQ,		:NumberOfItemsQ],
				[:ASizeB,		:NumberOfItemsB],
				[:ALength,		:NumberOfItems],
				[:ALengthQ,		:NumberOfItemsQ],
				[:ALengthB,		:NumberOfItemsB],

				# NumberOfItems CS aliases
				[:SizeCS,		:NumberOfItemsCS],
				[:SizeCSQ,		:NumberOfItemsCSQ],
				[:SizeCSB,		:NumberOfItemsCSB],
				[:LengthCS,		:NumberOfItemsCS],
				[:LengthCSQ,		:NumberOfItemsCSQ],
				[:LengthCSB,		:NumberOfItemsCSB],
				[:CountItemsCS,		:NumberOfItemsCS],
				[:CountItemsCSQ,	:NumberOfItemsCSQ],
				[:CountItemsCSB,	:NumberOfItemsCSB],
				[:HowManyItemsCS,	:NumberOfItemsCS],
				[:HowManyItemsCSQ,	:NumberOfItemsCSQ],
				[:HowManyItemsCSB,	:NumberOfItemsCSB],
				[:ANumberOfItemsCS,	:NumberOfItemsCS],
				[:ASizeCS,		:NumberOfItemsCS],
				[:ALengthCS,		:NumberOfItemsCS],

				# NumberOfItems U aliases
				[:SizeU,		:NumberOfItemsU],
				[:LengthU,		:NumberOfItemsU],
				[:CountItemsU,		:NumberOfItemsU],
				[:HowManyItemsU,	:NumberOfItemsU],
				[:HowManyItemU,		:NumberOfItemsU],

				# NumberOfItems misspelled
				[:NuberOfItems,		:NumberOfItems],
				[:Lenght,		:NumberOfItems],
				[:LenghtQ,		:NumberOfItemsQ],
				[:NuberOfItemsCS,	:NumberOfItemsCS],
				[:LenghtCS,		:NumberOfItemsCS],
				[:LenghtCSQ,		:NumberOfItemsCSQ],
				[:LenghtU,		:NumberOfItemsU],

				# NFirstItems aliases
				[:FirstN,		:NFirstItems],
				[:FirstNItems,		:NFirstItems],
				[:FirstNItemsQ,		:NFirstItemsQ],
				[:FirstNItemsQRT,	:NFirstItemsQRT],

				# NFirstItems misspelled
				[:NFristItems,		:NFirstItems],
				[:NFristItemsQ,		:NFirstItemsQ],
				[:NFristItemsQRT,	:NFirstItemsQRT],
				[:FristNItems,		:NFirstItems],
				[:FristNItemsQ,		:NFirstItemsQ],
				[:FristNItemsQRT,	:NFirstItemsQRT],

				# NLastItems aliases
				[:LastNItems,		:NLastItems],
				[:LastNItemsQ,		:NLastItemsQ],
				[:LastNItemsQRT,	:NLastItemsQRT],

				# First/Last misspelled
				[:FristItem,		:FirstItem],
				[:FristItemQ,		:FirstItemQ],
				[:FristAndLastItems,	:FirstAndLastItems],
				[:LastAndFristItems,	:LastAndFirstItems],

				# Update aliases
				[:UpdateUsing,		:Update],
				[:UpdateUsingQ,		:UpdateQ],
				[:Fill,			:Update],
				[:FillQ,		:UpdateQ],
				[:FillWith,		:Update],
				[:FillWithQ,		:UpdateQ],
				[:FillBy,		:Update],
				[:FillByQ,		:UpdateQ],
				[:FillUsing,		:Update],
				[:FillUsingQ,		:UpdateQ],

				# Updated aliases
				[:UpdatedUsing,		:Updated],
				[:Filled,		:Updated],
				[:FilledWith,		:Updated],
				[:FilledBy,		:Updated],
				[:FilledUsing,		:Updated],

				# Add aliases
				[:AppendWith,		:AddItem],
				[:AppendWithQ,		:AddItemQ],
				[:AppendedWith,		:ItemAdded],
				[:Appended,		:ItemAdded],
				[:AddItems,		:AddMany],

				# Show aliases
				[:Shwo,			:Show],
				[:ShwoShort,		:ShowShort],
				[:ShowShortCopy,	:ShowShort]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next

		ok
