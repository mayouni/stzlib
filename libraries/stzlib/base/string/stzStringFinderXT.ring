#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGFINDERXT           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Extended string finder -- adds all          #
#                  Softanza method aliases to stzStringFinder   #
#                  via addmethod() for full fluency.            #
#                  Use stzStringFinder for lean canonical API.  #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzStringFinderXTQ(str)
	return new stzStringFinderXT(str)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringFinderXT from stzStringFinder

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

			# --- ContainsCS aliases ---

			[ "ContainsSubStringCS",        "ContainsCS" ],
			[ "ContainingCS",               "ContainsCS" ],
			[ "ContainsNoCS",               "_ContainsNoCS" ],
			[ "DoesNotContainCS",           "_ContainsNoCS" ],

			# --- Contains aliases ---

			[ "ContainsSubString",          "Contains" ],
			[ "Containing",                 "Contains" ],
			[ "ContainsNo",                 "_ContainsNo" ],
			[ "DoesNotContain",             "_ContainsNo" ],

			# --- ContainsThese aliases ---

			[ "ContainsTheseSubStringsCS",  "ContainsTheseCS" ],
			[ "ContainsTheseSubStrings",    "ContainsThese" ],

			# --- FindCS aliases ---

			[ "FindAllCS",                  "FindCS" ],
			[ "FindSubStringCS",            "FindCS" ],
			[ "OccurrencesCS",              "FindCS" ],
			[ "PositionsCS",                "FindCS" ],
			[ "PositionsOfSubStringCS",     "FindCS" ],

			# --- Find aliases ---

			[ "FindAll",                    "Find" ],
			[ "FindSubString",              "Find" ],
			[ "Occurrences",                "Find" ],
			[ "Positions",                  "Find" ],
			[ "PositionsOfSubString",       "Find" ],

			# --- FindNthCS aliases ---

			[ "FindNthOccurrenceCS",        "FindNthCS" ],
			[ "FindNthSubStringCS",         "FindNthCS" ],
			[ "NthOccurrenceCS",            "FindNthCS" ],
			[ "PositionOfNthCS",            "FindNthCS" ],

			# --- FindNth aliases ---

			[ "FindNthOccurrence",          "FindNth" ],
			[ "FindNthSubString",           "FindNth" ],
			[ "NthOccurrence",              "FindNth" ],
			[ "PositionOfNth",              "FindNth" ],

			# --- FindFirstCS aliases ---

			[ "FindFirstOccurrenceCS",      "FindFirstCS" ],
			[ "FirstOccurrenceCS",          "FindFirstCS" ],
			[ "FindFirstSubStringCS",       "FindFirstCS" ],
			[ "FirstPositionCS",            "FindFirstCS" ],
			[ "PositionOfFirstCS",          "FindFirstCS" ],

			# --- FindFirst aliases ---

			[ "FindFirstOccurrence",        "FindFirst" ],
			[ "FirstOccurrence",            "FindFirst" ],
			[ "FindFirstSubString",         "FindFirst" ],
			[ "FirstPosition",              "FindFirst" ],
			[ "PositionOfFirst",            "FindFirst" ],

			# --- FindLastCS aliases ---

			[ "FindLastOccurrenceCS",       "FindLastCS" ],
			[ "FindLastSubStringCS",        "FindLastCS" ],
			[ "LastOccurrenceCS",           "FindLastCS" ],
			[ "PositionOfLastCS",           "FindLastCS" ],
			[ "LastPositionCS",             "FindLastCS" ],

			# --- FindLast aliases ---

			[ "FindLastOccurrence",         "FindLast" ],
			[ "FindLastSubString",          "FindLast" ],
			[ "LastOccurrence",             "FindLast" ],
			[ "PositionOfLast",             "FindLast" ],
			[ "LastPosition",               "FindLast" ],

			# --- NumberOfOccurrenceCS aliases ---

			[ "NumberOfOccurrencesCS",      "NumberOfOccurrenceCS" ],
			[ "NumberOfOccurrencesOfCS",    "NumberOfOccurrenceCS" ],
			[ "NumberOfOccurrenceOfCS",     "NumberOfOccurrenceCS" ],
			[ "HowManyCS",                  "NumberOfOccurrenceCS" ],
			[ "NumberOfCS",                 "NumberOfOccurrenceCS" ],
			[ "CountCS",                    "NumberOfOccurrenceCS" ],
			[ "CountOfCS",                  "NumberOfOccurrenceCS" ],

			# --- NumberOfOccurrence aliases ---

			[ "NumberOfOccurrences",        "NumberOfOccurrence" ],
			[ "NumberOfOccurrencesOf",       "NumberOfOccurrence" ],
			[ "HowMany",                    "NumberOfOccurrence" ],
			[ "NumberOf",                   "NumberOfOccurrence" ],
			[ "Count",                      "NumberOfOccurrence" ],
			[ "CountOf",                    "NumberOfOccurrence" ],

			# --- FindMany aliases ---

			[ "FindManySubStringsCS",       "FindManyCS" ],
			[ "FindManySubStrings",         "FindMany" ],

			# --- StartsWith aliases ---

			[ "BeginsWithCS",               "StartsWithCS" ],
			[ "BeginsWith",                 "StartsWith" ],

			# --- EndsWith aliases ---

			[ "FinishesWithCS",             "EndsWithCS" ],
			[ "FinishesWith",               "EndsWith" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next

	  #-------------------------------------------------#
	 #  NEGATION HELPERS (needed by addmethod aliases)  #
	#-------------------------------------------------#

	def _ContainsNoCS(pcSubStr, pCaseSensitive)
		return NOT This.ContainsCS(pcSubStr, pCaseSensitive)

	def _ContainsNo(pcSubStr)
		return NOT This.Contains(pcSubStr)

