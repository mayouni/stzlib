#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZSTRINGXT               #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Extended root string class -- adds all      #
#                  Softanza method aliases to stzString via     #
#                  addmethod() for full fluency.                #
#                  Use stzString for lean canonical API.        #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringXT from stzString

	_bAliasesLoaded = FALSE

	def init(pcStr)
		super.init(pcStr)
		This._RegisterAliases()

	def _RegisterAliases()

		if _bAliasesLoaded
			return
		ok

		_bAliasesLoaded = TRUE

		_aAliases_ = [

			# --- Content aliases ---

			[ "Value",                      "Content" ],
			[ "String",                     "Content" ],
			[ "TheString",                  "Content" ],
			[ "R",                          "Content" ],
			[ "AsWell",                     "Content" ],
			[ "AsWellR",                    "Content" ],

			# --- NumberOfChars aliases ---

			[ "Size",                       "NumberOfChars" ],
			[ "Len",                        "NumberOfChars" ],
			[ "Length",                      "NumberOfChars" ],
			[ "NChars",                     "NumberOfChars" ],
			[ "NumberOfItems",              "NumberOfChars" ],
			[ "SizeInChars",                "NumberOfChars" ],
			[ "CountChars",                 "NumberOfChars" ],
			[ "HowManyChars",               "NumberOfChars" ],
			[ "HowManyChar",                "NumberOfChars" ],

			# --- Update aliases ---

			[ "SetContent",                 "Update" ],
			[ "UpdateWith",                 "Update" ],
			[ "UpdateBy",                   "Update" ],
			[ "UpdateUsing",                "Update" ],
			[ "Fill",                       "Update" ],
			[ "FillWith",                   "Update" ],
			[ "FillBy",                     "Update" ],
			[ "FillUsing",                  "Update" ],

			# --- Copy aliases ---

			[ "Clone",                      "Copy" ],
			[ "Duplicate",                  "Copy" ],

			# --- IsEqualToCS aliases ---

			[ "IsEqualCS",                  "IsEqualToCS" ],
			[ "EqualToCS",                  "IsEqualToCS" ],
			[ "EqualsCS",                   "IsEqualToCS" ],
			[ "HasSameContentAsCS",         "IsEqualToCS" ],
			[ "HasSameValueAsCS",           "IsEqualToCS" ],

			# --- IsEqualTo aliases ---

			[ "IsEqual",                    "IsEqualTo" ],
			[ "EqualTo",                    "IsEqualTo" ],
			[ "Equals",                     "IsEqualTo" ],
			[ "HasSameContentAs",           "IsEqualTo" ],
			[ "HasSameValueAs",             "IsEqualTo" ],

			# --- Chars aliases ---

			[ "ToListOfChars",              "Chars" ],

			# --- ClassName aliases ---

			[ "StzClassName",               "ClassName" ],
			[ "StzClass",                   "ClassName" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next

	  #-------------------------------------------------#
	 #  CANONICAL METHODS (needed by addmethod aliases) #
	#-------------------------------------------------#

	def IsEqualToCS(pcOtherStr, pCaseSensitive)
		bCase = @CaseSensitive(pCaseSensitive)
		if bCase
			return This.Content() = pcOtherStr
		else
			return lower(This.Content()) = lower(pcOtherStr)
		ok

	def IsEqualTo(pcOtherStr)
		return This.IsEqualToCS(pcOtherStr, 1)

	def Chars()
		acResult = []
		cContent = This.Content()
		nLen = len(cContent)
		for i = 1 to nLen
			acResult + substr(cContent, i, 1)
		next
		return acResult

	def ClassName()
		return "stzstring"
