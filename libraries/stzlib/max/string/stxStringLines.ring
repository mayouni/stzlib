#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STXSTRINGLINES            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String lines extended class -- aliases      #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stxStringLines from stzStringLines

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

			# --- Lines aliases ---

			[ "AllLines",			"Lines" ],
			[ "LineCount",			"NumberOfLines" ],

			# --- NthLine aliases ---

			[ "TheLine",			"NthLine" ],

			# --- FirstLine / LastLine aliases ---

			[ "TheFirstLine",		"FirstLine" ],
			[ "TheLastLine",		"LastLine" ],

			# --- NFirstLines / NLastLines aliases ---

			[ "FirstNLines",		"NFirstLines" ],
			[ "LastNLines",			"NLastLines" ],

			# --- UniqueLines aliases ---

			[ "DistinctLines",		"UniqueLines" ],

			# --- LongestLine / ShortestLine aliases ---

			[ "TheLongestLine",		"LongestLine" ],
			[ "TheShortestLine",		"ShortestLine" ],

			# --- AverageLineLength aliases ---

			[ "MeanLineLength",		"AverageLineLength" ],

			# --- SortLines aliases ---

			[ "OrderLines",			"SortLines" ],
			[ "OrderLinesQ",		"SortLinesQ" ],
			[ "LinesOrdered",		"LinesSorted" ],

			# --- ReverseLinesOrder aliases ---

			[ "FlipLines",			"ReverseLinesOrder" ],
			[ "FlipLinesQ",			"ReverseLinesOrderQ" ],
			[ "LinesFlipped",		"LinesOrderReversed" ],

			# --- IndentLines aliases ---

			[ "Indent",			"IndentLines" ],
			[ "IndentQ",			"IndentLinesQ" ],
			[ "Indented",			"LinesIndented" ],

			# --- RemoveDuplicateLines aliases ---

			[ "Dedup",			"RemoveDuplicateLines" ],
			[ "DedupQ",			"RemoveDuplicateLinesQ" ],
			[ "Deduped",			"DuplicateLinesRemoved" ],

			# --- RemoveEmptyLines aliases ---

			[ "ClearEmptyLines",		"RemoveEmptyLines" ],
			[ "ClearEmptyLinesQ",		"RemoveEmptyLinesQ" ],
			[ "EmptyLinesCleared",		"EmptyLinesRemoved" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
