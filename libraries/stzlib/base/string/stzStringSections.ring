#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGSECTIONS           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String sections subclass -- extracting      #
#                  sections and ranges from strings.            #
#                  For aliases, use stzStringSectionsXT.        #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringSections from stzString

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
		nLen = This.NumberOfChars()
		if n1 < 1
			n1 = 1
		ok
		if n2 > nLen
			n2 = nLen
		ok
		if n1 > n2
			temp = n1
			n1 = n2
			n2 = temp
		ok
		return substr(This.Content(), n1, n2 - n1 + 1)

	def Section(n1, n2)
		return This.SectionCS(n1, n2, 1)

	  #======================================================#
	 #   RANGE                                              #
	#======================================================#

	def Range(pnStart, pnRange)
		return This.Section(pnStart, pnStart + pnRange - 1)
