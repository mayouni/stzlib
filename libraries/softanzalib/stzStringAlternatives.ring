

class stzAlternatives

		  #------------------------------------#
		 #  ALTERNATIVES OF FindSplittedBy()  #
		#------------------------------------#

		def FindSeparatedByCS(pcSubStr, pCaseSensitive)
			return This.FindSplittedByCS(pcSubStr, pCaseSensitive)

			#< @FunctionFluentForms

			def FindSeparatedByCSQ(pcSubStr, pCaseSensitive)
				return This.FindSplittedByCSQR(pcSubStr, pCaseSensitive, :stzList)

			def FindSeparatedByCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				return This.FindSplittedByCSQR(pcSubStr, :CaseSensitive = TRUE, pcReturnType)				
	
			#>

		#-- WITHOUT CASESENSITIVITY

		def FindSeparatedBy(pcSubStr)
			return This.FindSplittedBy(pcSubStr)			

			#< @FunctionFluentForms

			def FindSeparatedByQ(pcSubStr)
				return This.FindSeparatedByQR(pcSubStr, :stzList)

			def FindSeparatedByQR(pcSubStr, pcReturnType)
				return This.FindSplittedByCSQR(pcSubStr, :CaseSensitive = TRUE, pcReturnType)				

			#>

		  #---------------------------------------------#
		 #  ALTERNATIVE OF FindSplittedByAsSections()  #
		#---------------------------------------------#

		def FindSeparatedByAsSectionsCS(pcSubStr, pCaseSensitive)
			return This.FindSplittedByAsSectionsCS(pcSubStr, pCaseSensitive)

			def FindSeparatedByAsSectionsCSQ(pcSubStr, pCaseSensitive)
				return This.FindSeparatedByAsSectionsCSQR(pcSubStr, pCaseSensitive, :stzList)

			def FindSeparatedByAsSectionsCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				return This.FindSplittedByAsSectionsCSQR(pcSubStr, :CaseSensitive = TRUE, pcReturnType)				

		#-- WITHOUT CASESENSITIVITY

		def FindSeparatedByAsSections(pcSubStr)
			return This.FindSplittedByAsSectionsCS(pcSubStr, :CaseSensitive = TRUE)

			def FindSeparatedByAsSectionsQ(pcSubStr)
				return This.FindSeparatedByAsSectionsQR(pcSubStr, :stzList)

			def FindSeparatedByAsSectionsQR(pcSubStr, pcReturnType)
				return This.FindSplittedByAsSectionsCSQR(pcSubStr, :CaseSensitive = TRUE, pcReturnType)				


		  #---------------------------------------#
		 #  ALTERNATIVES OF SubstringsBetween()  #
		#---------------------------------------#

		def SubStringsBoundedByCS(pacBounds, pCaseSensitive)
			acResult = []
			if isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				acResult = This.SubStringsBetweenCS(pacBounds[1], pacBounds[2], pCaseSensitive)
			ok

			return acResult

			def SubStringsBoundedByCSQ(pacBounds, pCaseSensitive)
				return This.SubStringsBoundedByCSQR(pacBounds, pCaseSensitive, :stzList)

			def SubStringsBoundedByCSQR(pacBounds, pCaseSensitive, pcReturnType)
				return This.SubStringsBetweenCSQR(pacBounds[1], pacBounds[2], pCaseSensitive, pcReturnType)

		def BoundedByCS(pacBounds, pCaseSensitive)
			acResult = []
			if isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				acResult = This.SubStringsBetweenCS(pacBounds[1], pacBounds[2], pCaseSensitive)
			ok

			return acResult

			def BoundedByCSQ(pacBounds, pCaseSensitive)
				return This.BoundedByCSQR(pacBounds, pCaseSensitive, :stzList)

			def BoundedByCSQR(pacBounds, pCaseSensitive, pcReturnType)
				return This.SubStringsBetweenCSQR(pacBounds[1], pacBounds[2], pCaseSensitive, pcReturnType)

		#--

		def AnySubStringBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubStringsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySubStringBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.SubStringsBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySubStringBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				return This.SubStringsBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)

		def AnySubStringBoundedByCS(pacBounds, pCaseSensitive)
			return This.SubStringsBoundedByCS(pacBounds, pCaseSensitive)

			def AnySubStringBoundedByCSQ(pacBounds, pCaseSensitive)
				return This.SubStringsBoundedByCSQ(pacBounds, pCaseSensitive)

			def AnySubStringBoundedByCSQR(pacBounds, pCaseSensitive, pcReturnType)
				return This.SubStringsBoundedByCSQR(pacBounds, pCaseSensitive, pcReturnType)

		#--

		def AnySubStringsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubStringsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySubStringsBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.SubStringsBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySubStringsBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				return This.SubStringsBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)

		def AnySubStringsBoundedByCS(pacBounds, pCaseSensitive)
			return This.SubStringsBoundedByCS(pacBounds, pCaseSensitive)

			def AnySubStringsBoundedByCSQ(pacBounds, pCaseSensitive)
				return This.SubStringsBoundedByCSQ(pacBounds, pCaseSensitive)

			def AnySubStringsBoundedByCSQR(pacBounds, pCaseSensitive, pcReturnType)
				return This.SubStringsBoundedByCSQR(pacBounds, pCaseSensitive, pcReturnType)

		#-- Allowing the use of "SECTION" along with "SUBSTRING"

		def SectionsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def SectionsBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.SubStringsBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)

		def SectionsBoundedByCS(pacBounds, pCaseSensitive)
			return This.SubstringsBoundedByCS(pacBounds, pCaseSensitive)

			def SectionsBoundedByCSQ(pacBounds, pCaseSensitive)
				return This.SubStringsBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)

		#--

		def AnySectionBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SectionsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySectionBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.SectionsBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySectionBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				return This.SectionsBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)

		def AnySectionBoundedByCS(pacBounds, pCaseSensitive)
			return This.SectionsBoundedByCS(pacBounds, pCaseSensitive)

			def AnySectionBoundedByCSQ(pacBounds, pCaseSensitive)
				return This.SectionsBoundedByCSQ(pacBounds, pCaseSensitive)

			def AnySectionBoundedByCSQR(pacBounds, pCaseSensitive, pcReturnType)
				return This.SectionsBoundedByCSQR(pacBounds, pCaseSensitive, pcReturnType)

		#--

		def AnySectionsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SectionsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySectionsBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.SectionsBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySectionsBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				return This.SectionsBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)

		def AnySectionsBoundedByCS(pacBounds, pCaseSensitive)
			return This.SectionsBoundedByCS(pacBounds, pCaseSensitive)

			def AnySectionsBoundedByCSQ(pacBounds, pCaseSensitive)
				return This.SectionsBoundedByCSQ(pacBounds, pCaseSensitive)

			def AnySectionsBoundedByCSQR(pacBounds, pCaseSensitive, pcReturnType)
				return This.SectionsBoundedByCSQR(pacBounds, pCaseSensitive, pcReturnType)

		#-- WITHOUT CASESENSITIVITY

		def SubStringsBoundedBy(pacBounds)
			acResult = []
			if isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				acResult = This.SubStringsBetween(pacBounds[1], pacBounds[2])
			ok

			return acResult

			def SubStringsBoundedByQ(pacBounds)
				return This.SubStringsBoundedByQR(pacBounds,  :stzList)

			def SubStringsBoundedByQR(pacBounds,  pcReturnType)
				return This.SubStringsBetweenQR(pacBounds[1], pacBounds[2],  pcReturnType)

		def BoundedBy(pacBounds)
			acResult = []
			if isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				acResult = This.SubStringsBetween(pacBounds[1], pacBounds[2])
			ok

			return acResult

			def BoundedByQ(pacBounds)
				return This.BoundedByQR(pacBounds,  :stzList)

			def BoundedByQR(pacBounds,  pcReturnType)
				return This.SubStringsBetweenQR(pacBounds[1], pacBounds[2],  pcReturnType)

		#--

		def AnySubStringBetween(pcSubStr1, pcSubStr2)
			return This.SubStringsBetween(pcSubStr1, pcSubStr2)

			def AnySubStringBetweenQ(pcSubStr1, pcSubStr2)
				return This.SubStringsBetweenQ(pcSubStr1, pcSubStr2)

			def AnySubStringBetweenQR(pcSubStr1, pcSubStr2,  pcReturnType)
				return This.SubStringsBetweenQR(pcSubStr1, pcSubStr2,  pcReturnType)

		def AnySubStringBoundedBy(pacBounds)
			return This.SubStringsBoundedBy(pacBounds)

			def AnySubStringBoundedByQ(pacBounds)
				return This.SubStringsBoundedByQ(pacBounds)

			def AnySubStringBoundedByQR(pacBounds,  pcReturnType)
				return This.SubStringsBoundedByQR(pacBounds,  pcReturnType)

		#--

		def AnySubStringsBetween(pcSubStr1, pcSubStr2)
			return This.SubStringsBetween(pcSubStr1, pcSubStr2)

			def AnySubStringsBetweenQ(pcSubStr1, pcSubStr2)
				return This.SubStringsBetweenQ(pcSubStr1, pcSubStr2)

			def AnySubStringsBetweenQR(pcSubStr1, pcSubStr2,  pcReturnType)
				return This.SubStringsBetweenQR(pcSubStr1, pcSubStr2,  pcReturnType)

		def AnySubStringsBoundedBy(pacBounds)
			return This.SubStringsBoundedBy(pacBounds)

			def AnySubStringsBoundedByQ(pacBounds)
				return This.SubStringsBoundedByQ(pacBounds)

			def AnySubStringsBoundedByQR(pacBounds,  pcReturnType)
				return This.SubStringsBoundedByQR(pacBounds,  pcReturnType)

		#-- Allowing the use of "SECTION" along with "SUBSTRING"

		def SectionsBetween(pcSubStr1, pcSubStr2)
			return This.SubstringsBetween(pcSubStr1, pcSubStr2)

			def SectionsBetweenQ(pcSubStr1, pcSubStr2)
				return This.SubStringsBetweenQ(pcSubStr1, pcSubStr2)

		def SectionsBoundedBy(pacBounds)
			return This.SubstringsBoundedBy(pacBounds)

			def SectionsBoundedByQ(pacBounds)
				return This.SubStringsBetweenQ(pcSubStr1, pcSubStr2)

		#--

		def AnySectionBetween(pcSubStr1, pcSubStr2)
			return This.SectionsBetween(pcSubStr1, pcSubStr2)

			def AnySectionBetweenQ(pcSubStr1, pcSubStr2)
				return This.SectionsBetweenQ(pcSubStr1, pcSubStr2)

			def AnySectionBetweenQR(pcSubStr1, pcSubStr2,  pcReturnType)
				return This.SectionsBetweenQR(pcSubStr1, pcSubStr2,  pcReturnType)

		def AnySectionBoundedBy(pacBounds)
			return This.SectionsBoundedBy(pacBounds)

			def AnySectionBoundedByQ(pacBounds)
				return This.SectionsBoundedByQ(pacBounds)

			def AnySectionBoundedByQR(pacBounds,  pcReturnType)
				return This.SectionsBoundedByQR(pacBounds,  pcReturnType)

		#--

		def AnySectionsBetween(pcSubStr1, pcSubStr2)
			return This.SectionsBetween(pcSubStr1, pcSubStr2)

			def AnySectionsBetweenQ(pcSubStr1, pcSubStr2)
				return This.SectionsBetweenQ(pcSubStr1, pcSubStr2)

			def AnySectionsBetweenQR(pcSubStr1, pcSubStr2,  pcReturnType)
				return This.SectionsBetweenQR(pcSubStr1, pcSubStr2,  pcReturnType)

		def AnySectionsBoundedBy(pacBounds)
			return This.SectionsBoundedBy(pacBounds)

			def AnySectionsBoundedByQ(pacBounds)
				return This.SectionsBoundedByQ(pacBounds)

			def AnySectionsBoundedByQR(pacBounds,  pcReturnType)
				return This.SectionsBoundedByQR(pacBounds,  pcReturnType)

		  #-----------------------------------------#
		 #  ALTERNATIVES OF SubstringsBetweenIB()  #
		#-----------------------------------------#

		def SubStringsBoundedByIBCS(pacBounds, pCaseSensitive)
			acResult = []
			if isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				acResult = This.SubStringsBetweenIBCS(pacBounds[1], pacBounds[2], pCaseSensitive)
			ok

			return acResult

			def SubStringsBoundedByIBCSQ(pacBounds, pCaseSensitive)
				return This.SubStringsBoundedByIBCSQR(pacBounds, pCaseSensitive, :stzList)

			def SubStringsBoundedByIBCSQR(pacBounds, pCaseSensitive, pcReturnType)
				return This.SubStringsBetweenIBCSQR(pacBounds[1], pacBounds[2], pCaseSensitive, pcReturnType)

		#--

		def BoundedByIBCS(pacBounds, pCaseSensitive)
			acResult = []
			if isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				acResult = This.SubStringsBetweenIBCS(pacBounds[1], pacBounds[2], pCaseSensitive)
			ok

			return acResult

			def BoundedByIBCSQ(pacBounds, pCaseSensitive)
				return This.BoundedByIBCSQR(pacBounds, pCaseSensitive, :stzList)

			def BoundedByIBCSQR(pacBounds, pCaseSensitive, pcReturnType)
				return This.SubStringsBetweenIBCSQR(pacBounds[1], pacBounds[2], pCaseSensitive, pcReturnType)

		#--

		def AnySubStringBetweenIBCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubStringsBetweenIBCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySubStringBetweenIBCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.SubStringsBetweenIBCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySubStringBetweenIBCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				return This.SubStringsBetweenIBCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)

		def AnySubStringBoundedByIBCS(pacBounds, pCaseSensitive)
			return This.SubStringsBoundedByIBCS(pacBounds, pCaseSensitive)

			def AnySubStringBoundedByIBCSQ(pacBounds, pCaseSensitive)
				return This.SubStringsBoundedByIBCSQ(pacBounds, pCaseSensitive)

			def AnySubStringBoundedByIBCSQR(pacBounds, pCaseSensitive, pcReturnType)
				return This.SubStringsBoundedByIBCSQR(pacBounds, pCaseSensitive, pcReturnType)

		#--

		def AnySubStringsBetweenIBCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubStringsBetweenIBCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySubStringsBetweenIBCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.SubStringsBetweenIBCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySubStringsBetweenIBCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				return This.SubStringsBetweenIBCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)

		def AnySubStringsBoundedByIBCS(pacBounds, pCaseSensitive)
			return This.SubStringsBoundedByIBCS(pacBounds, pCaseSensitive)

			def AnySubStringsBoundedByIBCSQ(pacBounds, pCaseSensitive)
				return This.SubStringsBoundedByIBCSQ(pacBounds, pCaseSensitive)

			def AnySubStringsBoundedByIBCSQR(pacBounds, pCaseSensitive, pcReturnType)
				return This.SubStringsBoundedByIBCSQR(pacBounds, pCaseSensitive, pcReturnType)

		#-- Allowing the use of "SECTION" along with "SUBSTRING"

		def SectionsBetweenIBCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBetweenIBCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def SectionsBetweenIBCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.SubStringsBetweenIBCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)

		def SectionsBoundedByIBCS(pacBounds, pCaseSensitive)
			return This.SubstringsBoundedByIBCS(pacBounds, pCaseSensitive)

			def SectionsBoundedByIBCSQ(pacBounds, pCaseSensitive)
				return This.SubStringsBetweenIBCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)

		#--

		def AnySectionBetweenIBCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SectionsBetweenIBCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySectionBetweenIBCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.SectionsBetweenIBCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySectionBetweenIBCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				return This.SectionsBetweenIBCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)

		def AnySectionBoundedByIBCS(pacBounds, pCaseSensitive)
			return This.SectionsBoundedByCSIB(pacBounds, pCaseSensitive)

			def AnySectionBoundedByIBCSQ(pacBounds, pCaseSensitive)
				return This.SectionsBoundedByIBCSQ(pacBounds, pCaseSensitive)

			def AnySectionBoundedByIBCSQR(pacBounds, pCaseSensitive, pcReturnType)
				return This.SectionsBoundedByIBCSQR(pacBounds, pCaseSensitive, pcReturnType)

		#--

		def AnySectionsBetweenIBCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SectionsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySectionsBetweenIBCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.SectionsBetweenIBCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySectionsBetweenIBCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				return This.SectionsBetweenIBCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)

		def AnySectionsBoundedByIBCS(pacBounds, pCaseSensitive)
			return This.SectionsBoundedByIBCS(pacBounds, pCaseSensitive)

			def AnySectionsBoundedByIBCSQ(pacBounds, pCaseSensitive)
				return This.SectionsBoundedByCSQ(pacBounds, pCaseSensitive)

			def AnySectionsBoundedByIBCSQR(pacBounds, pCaseSensitive, pcReturnType)
				return This.SectionsBoundedByIBCSQR(pacBounds, pCaseSensitive, pcReturnType)

		#-- WITHOUT CASESENSITIVITY

		def SubStringsBoundedByIB(pacBounds)
			acResult = []
			if isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				acResult = This.SubStringsBetween(pacBounds[1], pacBounds[2])
			ok

			return acResult

			def SubStringsBoundedByIBQ(pacBounds)
				return This.SubStringsBoundedByIBQR(pacBounds,  :stzList)

			def SubStringsBoundedByIBQR(pacBounds,  pcReturnType)
				return This.SubStringsBetweenIBQR(pacBounds[1], pacBounds[2],  pcReturnType)

		#--

		def BoundedByIB(pacBounds)
			acResult = []
			if isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				acResult = This.SubStringsBetweenIB(pacBounds[1], pacBounds[2])
			ok

			return acResult

			def BoundedByIBQ(pacBounds)
				return This.BoundedByIBQR(pacBounds,  :stzList)

			def BoundedByIBQR(pacBounds, pcReturnType)
				return This.SubStringsBetweenIBQR(pacBounds[1], pacBounds[2],  pcReturnType)

		#--

		def AnySubStringBetweenIB(pcSubStr1, pcSubStr2)
			return This.SubStringsBetweenIB(pcSubStr1, pcSubStr2)

			def AnySubStringBetweenIBQ(pcSubStr1, pcSubStr2)
				return This.SubStringsBetweenIBQ(pcSubStr1, pcSubStr2)

			def AnySubStringBetweenIBQR(pcSubStr1, pcSubStr2,  pcReturnType)
				return This.SubStringsBetweenIBQR(pcSubStr1, pcSubStr2,  pcReturnType)

		def AnySubStringBoundedByIB(pacBounds)
			return This.SubStringsBoundedByIB(pacBounds)

			def AnySubStringBoundedByIBQ(pacBounds)
				return This.SubStringsBoundedByIBQ(pacBounds)

			def AnySubStringBoundedByIBQR(pacBounds,  pcReturnType)
				return This.SubStringsBoundedByIBQR(pacBounds,  pcReturnType)

		#--

		def AnySubStringsBetweenIB(pcSubStr1, pcSubStr2)
			return This.SubStringsBetweenIB(pcSubStr1, pcSubStr2)

			def AnySubStringsBetweenIBQ(pcSubStr1, pcSubStr2)
				return This.SubStringsBetweenIBQ(pcSubStr1, pcSubStr2)

			def AnySubStringsBetweenIBQR(pcSubStr1, pcSubStr2,  pcReturnType)
				return This.SubStringsBetweenIBQR(pcSubStr1, pcSubStr2,  pcReturnType)

		def AnySubStringsBoundedByIB(pacBounds)
			return This.SubStringsBoundedByIB(pacBounds)

			def AnySubStringsBoundedByIBQ(pacBounds)
				return This.SubStringsBoundedByIBQ(pacBounds)

			def AnySubStringsBoundedByIBQR(pacBounds,  pcReturnType)
				return This.SubStringsBoundedByIBQR(pacBounds,  pcReturnType)

		#-- Allowing the use of "SECTION" along with "SUBSTRING"

		def SectionsBetweenIB(pcSubStr1, pcSubStr2)
			return This.SubstringsBetweenIB(pcSubStr1, pcSubStr2)

			def SectionsBetweenIBQ(pcSubStr1, pcSubStr2)
				return This.SubStringsBetweenIBQ(pcSubStr1, pcSubStr2)

		def SectionsBoundedByIB(pacBounds)
			return This.SubstringsBoundedByIB(pacBounds)

			def SectionsBoundedByIBQ(pacBounds)
				return This.SubStringsBetweenIBQ(pcSubStr1, pcSubStr2)

		#--

		def AnySectionBetweenIB(pcSubStr1, pcSubStr2)
			return This.SectionsBetweenIB(pcSubStr1, pcSubStr2)

			def AnySectionBetweenIBQ(pcSubStr1, pcSubStr2)
				return This.SectionsBetweenIBQ(pcSubStr1, pcSubStr2)

			def AnySectionBetweenIBQR(pcSubStr1, pcSubStr2,  pcReturnType)
				return This.SectionsBetweenIBQR(pcSubStr1, pcSubStr2,  pcReturnType)

		def AnySectionBoundedByIB(pacBounds)
			return This.SectionsBoundedByIB(pacBounds)

			def AnySectionBoundedByIBQ(pacBounds)
				return This.SectionsBoundedByIBQ(pacBounds)

			def AnySectionBoundedByIBQR(pacBounds,  pcReturnType)
				return This.SectionsBoundedByIBQR(pacBounds,  pcReturnType)

		#--

		def AnySectionsBetweenIB(pcSubStr1, pcSubStr2)
			return This.SectionsBetweenIB(pcSubStr1, pcSubStr2)

			def AnySectionsBetweenIBQ(pcSubStr1, pcSubStr2)
				return This.SectionsBetweenIBQ(pcSubStr1, pcSubStr2)

			def AnySectionsBetweenIBQR(pcSubStr1, pcSubStr2,  pcReturnType)
				return This.SectionsBetweenIBQR(pcSubStr1, pcSubStr2,  pcReturnType)

		def AnySectionsBoundedByIB(pacBounds)
			return This.SectionsBoundedByIB(pacBounds)

			def AnySectionsBoundedByIBQ(pacBounds)
				return This.SectionsBoundedByIBQ(pacBounds)

			def AnySectionsBoundedByIBQR(pacBounds,  pcReturnType)
				return This.SectionsBoundedByQR(pacBounds,  pcReturnType)

		  #----------------------------------------#
		 #  ALTERNATIVES OF SubstringsBetweenU()  #
		#----------------------------------------#

		def UniqueSubStringsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBetweenCSU(pcSubStr1, pcSubStr2, pCaseSensitive)

		#--

		def UniqueSubStringsBoundedByCS(pacBounds, pCaseSensitive)
			return This.SubstringsBetweenCSU(pacBounds[1], pacBounds[2], pCaseSensitive, :stzList)

			def UniqueSubStringsBoundedByCSQ(pacBounds, pCaseSensitive)
				return This.SubstringsBetweenCSUQ(pacBounds[1], pacBounds[2], pCaseSensitive)

			def UniqueSubstringsBoundedByCSQR(pacBounds, pCaseSensitive, pcReturnType)
				return This.SubstringsBetweenCSUQR(pacBounds[1], pacBounds[2], pCaseSensitive, pcReturnType)

		#--

		def UniqueSectionsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBetweenCSU(pcSubStr1, pcSubStr2, pCaseSensitive)

			def UniqueSectionsBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.SubstringsBetweenCSUQ(ppacBounds[1], pacBounds[2], pCaseSensitive)

			def UniqueSectionsBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				return This.SubstringsBetweenCSUQR(pacBounds[1], pacBounds[2], pCaseSensitive, pcReturnType)

		def UniqueSectionsBoundedByCS(pacBounds, pCaseSensitive)
			return This.SubstringsBetweenCSU(pacBounds[1], pacBounds[2], pCaseSensitive)

			def UniqueSectionsBoundedByCSQ(pacBounds, pCaseSensitive)
				return This.SubstringsBetweenCSUQ(pacBounds[1], pacBounds[2], pCaseSensitive)

			def UniqueSectionsBoundedByCSQR(pacBounds, pCaseSensitive, pcReturnType)
				return This.SubstringsBetweenCSUQR(pacBounds[1], pacBounds[2], pCaseSensitive, pcReturnType)

		#==

		def SubStringsBoundedByCSU(pacBounds, pCaseSensitive)
			return This.SubstringsBetweenCSU(pacBounds[1], pacBounds[2], pCaseSensitive, :stzList)

			def SubStringsBoundedByCSUQ(pacBounds, pCaseSensitive)
				return This.SubstringsBetweenCSUQ(pacBounds[1], pacBounds[2], pCaseSensitive)

			def SubstringsBoundedByCSUQR(pacBounds, pCaseSensitive, pcReturnType)
				return This.SubstringsBetweenCSUQR(pacBounds[1], pacBounds[2], pCaseSensitive, pcReturnType)

		#--

		def SectionsBetweenUCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBetweenUCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def SectionsBetweenCSUQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.SubstringsBetweenCSUQ(ppacBounds[1], pacBounds[2], pCaseSensitive)

			def USectionsBetweenCSUQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				return This.SubstringsBetweenCSUQR(pacBounds[1], pacBounds[2], pCaseSensitive, pcReturnType)

		def SectionsBoundedByCSU(pacBounds, pCaseSensitive)
			return This.SubstringsBetweenCSU(pacBounds[1], pacBounds[2], pCaseSensitive)

			def SectionsBoundedByCSUQ(pacBounds, pCaseSensitive)
				return This.SubstringsBetweenCSUQ(pacBounds[1], pacBounds[2], pCaseSensitive)

			def SectionsBoundedByCSUQR(pacBounds, pCaseSensitive, pcReturnType)
				return This.SubstringsBetweenCSUQR(pacBounds[1], pacBounds[2], pCaseSensitive, pcReturnType)

		#-- WITHOUT CASESENSITIVITY

		def UniqueSubStringsBetween(pcSubStr1, pcSubStr2)
			return This.SubstringsBetweenU(pcSubStr1, pcSubStr2)

		#--

		def UniqueSubStringsBoundedBy(pacBounds)
			return This.SubstringsBetweenU(pacBounds[1], pacBounds[2], :stzList)

			def UniqueSubStringsBoundedByQ(pacBounds)
				return This.SubstringsBetweenUQ(pacBounds[1], pacBounds[2])

			def UniqueSubstringsBoundedByQR(pacBounds, pcReturnType)
				return This.SubstringsBetweenUQR(pacBounds[1], pacBounds[2], pcReturnType)

		#--

		def UniqueSectionsBetween(pcSubStr1, pcSubStr2)
			return This.SubstringsBetweenU(pcSubStr1, pcSubStr2)

			def UniqueSectionsBetweenQ(pcSubStr1, pcSubStr2)
				return This.SubstringsBetweenUQ(ppacBounds[1], pacBounds[2])

			def UniqueSectionsBetweenQR(pcSubStr1, pcSubStr2, pcReturnType)
				return This.SubstringsBetweenUQR(pacBounds[1], pacBounds[2], pcReturnType)

		def UniqueSectionsBoundedBy(pacBounds)
			return This.SubstringsBetweenU(pacBounds[1], pacBounds[2])

			def UniqueSectionsBoundedByQ(pacBounds)
				return This.SubstringsBetweenUQ(pacBounds[1], pacBounds[2])

			def UniqueSectionsBoundedByQR(pacBounds, pcReturnType)
				return This.SubstringsBetweenUQR(pacBounds[1], pacBounds[2], pcReturnType)

		#==

		def SubStringsBoundedByU(pacBounds)
			return This.SubstringsBetweenU(pacBounds[1], pacBounds[2], :stzList)

			def SubStringsBoundedByUQ(pacBounds)
				return This.SubstringsBetweenUQ(pacBounds[1], pacBounds[2])

			def SubstringsBoundedByUQR(pacBounds, pcReturnType)
				return This.SubstringsBetweenUQR(pacBounds[1], pacBounds[2], pcReturnType)

		#--

		def SectionsBetweenU(pcSubStr1, pcSubStr2)
			return This.SubstringsBetweenU(pcSubStr1, pcSubStr2)

			def SectionsBetweenUQ(pcSubStr1, pcSubStr2)
				return This.SubstringsBetweenUQ(ppacBounds[1], pacBounds[2])

			def USectionsBetweenUQR(pcSubStr1, pcSubStr2, pcReturnType)
				return This.SubstringsBetweenUQR(pacBounds[1], pacBounds[2], pcReturnType)

		def SectionsBoundedByU(pacBounds)
			return This.SubstringsBetweenU(pacBounds[1], pacBounds[2])

			def SectionsBoundedByUQ(pacBounds)
				return This.SubstringsBetweenUQ(pacBounds[1], pacBounds[2])

			def SectionsBoundedByUQR(pacBounds, pcReturnType)
				return This.SubstringsBetweenUQR(pacBounds[1], pacBounds[2], pcReturnType)



