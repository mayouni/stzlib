#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGSECTIONS           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String sections -- Wraps stzString via      #
#                  composition. Extracting sections and ranges #
#                  from strings.                               #
#                  For aliases, use stzStringSectionsXT.       #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringSections

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringSections! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   SECTION (SLICE)                                    #
	#======================================================#

	def SectionCS(n1, n2, pCaseSensitive)
		if CheckingParams()
			if isList(n1) and IsOneOfTheseNamedParamsList(n1, [:From, :FromPosition, :StartingAt])
				n1 = n1[2]
			ok
			if isList(n2) and IsOneOfTheseNamedParamsList(n2, [:To, :ToPosition, :Until])
				n2 = n2[2]
			ok
		ok
		return @oString.Section(n1, n2)

	def Section(n1, n2)
		return This.SectionCS(n1, n2, 1)

	  #======================================================#
	 #   RANGE                                              #
	#======================================================#

	def Range(pnStart, pnRange)
		return This.Section(pnStart, pnStart + pnRange - 1)

	  #======================================================#
	 #   MULTIPLE SECTIONS                                  #
	#======================================================#

	def Sections(paSections)
		aResult = []
		nLen = len(paSections)
		for i = 1 to nLen
			aResult + This.Section(paSections[i][1], paSections[i][2])
		next
		return aResult

	  #======================================================#
	 #   ANTI-SECTIONS                                      #
	#======================================================#

	def AntiSections(paSections)
		nLen = @oString.NumberOfChars()
		aCovered = []
		nSLen = len(paSections)
		for i = 1 to nSLen
			n1 = paSections[i][1]
			n2 = paSections[i][2]
			if n1 > n2
				temp = n1
				n1 = n2
				n2 = temp
			ok
			for j = n1 to n2
				aCovered + j
			next
		next

		aResult = []
		nStart = 0
		for i = 1 to nLen
			bCovered = 0
			for k = 1 to len(aCovered)
				if aCovered[k] = i
					bCovered = 1
					exit
				ok
			next
			if bCovered = 0
				if nStart = 0
					nStart = i
				ok
			else
				if nStart > 0
					aResult + This.Section(nStart, i - 1)
					nStart = 0
				ok
			ok
		next
		if nStart > 0
			aResult + This.Section(nStart, nLen)
		ok
		return aResult

	  #======================================================#
	 #   SECTION BETWEEN POSITIONS                          #
	#======================================================#

	def SectionBetween(n1, n2)
		return This.Section(n1 + 1, n2 - 1)

	  #======================================================#
	 #   REMOVE SECTION                                     #
	#======================================================#

	def RemoveSection(n1, n2)
		nLen = @oString.NumberOfChars()
		if n1 < 1 n1 = 1 ok
		if n2 > nLen n2 = nLen ok
		if n1 > n2
			temp = n1
			n1 = n2
			n2 = temp
		ok
		pH = @oString.Engine()
		pR = StzEngineStringRemoveRange(pH, n1, n2 - n1 + 1)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def RemoveSectionQ(n1, n2)
			This.RemoveSection(n1, n2)
			return This

	def SectionRemoved(n1, n2)
		oCopy = new stzStringSections(@oString.Content())
		return oCopy.RemoveSectionQ(n1, n2).Content()

	  #======================================================#
	 #   REMOVE MANY SECTIONS                               #
	#======================================================#

	def RemoveSections(paSections)
		nLen = len(paSections)
		for i = nLen to 1 step -1
			This.RemoveSection(paSections[i][1], paSections[i][2])
		next

		def RemoveSectionsQ(paSections)
			This.RemoveSections(paSections)
			return This

	def SectionsRemoved(paSections)
		oCopy = new stzStringSections(@oString.Content())
		return oCopy.RemoveSectionsQ(paSections).Content()

	  #======================================================#
	 #   REMOVE RANGE                                       #
	#======================================================#

	def RemoveRange(pnStart, pnRange)
		This.RemoveSection(pnStart, pnStart + pnRange - 1)

		def RemoveRangeQ(pnStart, pnRange)
			This.RemoveRange(pnStart, pnRange)
			return This

	def RangeRemoved(pnStart, pnRange)
		oCopy = new stzStringSections(@oString.Content())
		return oCopy.RemoveRangeQ(pnStart, pnRange).Content()
