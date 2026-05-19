#--------------------------------------------------------------#
#       SOFTANZA LIBRARY (V0.9) - STZSTRINGVISUALIZER          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String visualizer -- Show(), VizFind(),     #
#                  Boxed(), and visual rendering operations.   #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringVisualizerXT.     #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringVisualizer

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringVisualizer! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     SHOW                      #
	#===============================#

	def Show()
		? @oString.Content()

	def ShowShort()
		nLen = @oString.NumberOfChars()
		if nLen <= 50
			? @oString.Content()
		else
			? @oString.Section(1, 47) + "..."
		ok

	def ShowNL()
		? @oString.Content() + NL

	  #===============================#
	 #     VIZFIND                   #
	#===============================#

	def VizFindCharCS(c, pCaseSensitive)
		if NOT ( isString(c) and StzLen(c) = 1 )
			return ""
		ok

		cResult = @@( @oString.Content() )
		oFinder = new stzStringFinder(@oString)
		anPos = oFinder.FindCS(c, pCaseSensitive)

		nChars = @oString.NumberOfChars()

		cViz = " "
		for i = 1 to nChars
			if StzFind(anPos, i) > 0
				cViz += "^"
			else
				cViz += "-"
			ok
		next

		return cResult + NL + cViz

	def VizFindChar(c)
		return This.VizFindCharCS(c, 1)

	def VizFindCS(pcSubStr, pCaseSensitive)
		cResult = @@( @oString.Content() )
		oFinder = new stzStringFinder(@oString)
		anPos = oFinder.FindCS(pcSubStr, pCaseSensitive)

		nSubLen = StzLen(pcSubStr)
		nChars = @oString.NumberOfChars()

		cViz = " "
		for i = 1 to nChars
			bMarked = 0
			nPosLen = len(anPos)
			for j = 1 to nPosLen
				if i >= anPos[j] and i < anPos[j] + nSubLen
					bMarked = 1
					exit
				ok
			next

			if bMarked
				cViz += "^"
			else
				cViz += "-"
			ok
		next

		return cResult + NL + cViz

	def VizFind(pcSubStr)
		return This.VizFindCS(pcSubStr, 1)

	  #===============================#
	 #     BOXED                     #
	#===============================#

	def Boxed()
		return This.BoxedXT([ :Line = :Thin, :AllCorners = :Round ])

	def BoxedXT(paOptions)
		cContent = @oString.Content()
		nLen = @oString.NumberOfChars()

		cCorner = "+"
		cHLine = "-"
		cVLine = "|"

		if isList(paOptions)
			nOptLen = len(paOptions)
			for i = 1 to nOptLen
				if isList(paOptions[i])
					if len(paOptions[i]) = 2
						if paOptions[i][1] = :AllCorners
							if paOptions[i][2] = :Round
								cCorner = "."
							ok
						ok
						if paOptions[i][1] = :Line
							if paOptions[i][2] = :Dashed
								cHLine = "-"
								cVLine = ":"
							ok
						ok
					ok
				ok
			next
		ok

		cTop = cCorner + ""
		for i = 1 to nLen + 2
			cTop += cHLine
		next
		cTop += cCorner

		cMid = cVLine + " " + cContent + " " + cVLine
		cBot = cCorner + ""
		for i = 1 to nLen + 2
			cBot += cHLine
		next
		cBot += cCorner

		return cTop + NL + cMid + NL + cBot

	def BoxedRounded()
		return This.BoxedXT([ :Line = :Thin, :AllCorners = :Round ])

	  #===============================#
	 #     CHARS BOXED               #
	#===============================#

	def EachCharBoxed()
		acResult = []
		cContent = @oString.Content()
		nLen = @oString.NumberOfChars()

		for i = 1 to nLen
			c = @oString.NthChar(i)
			oViz = new stzStringVisualizer(c)
			acResult + oViz.Boxed()
		next

		return acResult

	  #===============================#
	 #     STRINGIFICATION           #
	#===============================#

	def Stringify()
		return @@(@oString.Content())

	  #===============================#
	 #     HIGHLIGHTED               #
	#===============================#

	def HighlightCS(pcSubStr, pcMarker, pCaseSensitive)
		cContent = @oString.Content()
		cResult = @ReplaceCS(cContent, pcSubStr, pcMarker + pcSubStr + pcMarker, pCaseSensitive)
		return cResult

	def Highlight(pcSubStr, pcMarker)
		return This.HighlightCS(pcSubStr, pcMarker, 1)
