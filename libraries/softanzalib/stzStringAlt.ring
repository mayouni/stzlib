
func StzStringAltQ(pcStr)
	return new stzStringAlt(pcStr)

class stzStringAlt from stzString

	  #---------------------------#
	 #  ALTERNATIVES OF FindA()  #
	#---------------------------#

	def FindAllOccurrencesCS(pcSubStr, pCaseSensitive)
		return This.FindCS(pcSubStr, pCaseSensitive)

		def FindAllOccurrencesCSQ(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCSQR(pcSubStr, pCaseSensitive, :stzList)
				
		def FFindAllOccurrencesCSQR(pcSubStr, pCaseSensitive, pcReturnType)
			return This.FindQR(pcSubStr, pCaseSensitive, pcReturnType)

	def FindAllCS(pcSubStr, pCaseSensitive)
		return This.FindAllOccurrencFindCSesCS(pcSubStr, pCaseSensitive)

		def FindAllCSQ(pcSubStr, pCaseSensitive)
			return This.FindAllCSQR(pcSubStr, pCaseSensitive, :stzList)
				
		def FindAllCSQR(pcSubStr, pCaseSensitive, pcReturnType)
			return This.FindCSQR(pcSubStr, pCaseSensitive, pcReturnType)

	def FindSubstringCS(pcSubStr, pCaseSensitive)
			return This.FindCS(pcSubStr, pCaseSensitive)

		def FindSubstringCSQ(pcSubStr, pCaseSensitive)
				return This.FindSubstringCSQR(pcSubStr, pCaseSensitive, :stzList)
				
		def FindSubstringCSQR(pcSubStr, pCaseSensitive, pcReturnType)
			return This.FindCSQR(pcSubStr, pCaseSensitive, pcReturnType)

	def OccurrencesCS(pcSubStr, pCaseSensitive)
		return This.FindCS(pcSubStr, pCaseSensitive)

		def OccurrencesCSQ(pcSubStr, pCaseSensitive)
				return This.OccurrencesCSQR(pcSubStr, pCaseSensitive, :stzList)
				
		def OccurrencesCSQR(pcSubStr, pCaseSensitive, pcReturnType)
			return This.FindCSQR(pcSubStr, pCaseSensitive, pcReturnType)

	def PositionsCS(pcSubStr, pCaseSensitive)
		return This.FindCS(pcSubStr, pCaseSensitive)

		def PositionsCSQ(pcSubStr, pCaseSensitive)
			return This.PositionsCSQR(pcSubStr, pCaseSensitive, :stzList)
				
		def PositionsCSQR(pcSubStr, pCaseSensitive, pcReturnType)
			return This.FindCSQR(pcSubStr, pCaseSensitive, pcReturnType)

	def PositionsOfSubStringCS(pcSubStr, pCaseSensitive)
		return This.FindCS(pcSubStr, pCaseSensitive)

		def PositionsOfSubStringCSQ(pcSubStr, pCaseSensitive)
			return This.PositionsOfSubStringCSQR(pcSubStr, pCaseSensitive, :stzList)
				
		def PositionsOfSubStringCSQR(pcSubStr, pCaseSensitive, pcReturnType)
			return This.FindCSQR(pcSubStr, pCaseSensitive, pcReturnType)

	def FindPositionsCS(pcSubStr, pCaseSensitive)
		return This.FindCS(pcSubStr, pCaseSensitive)

		def FindPositionsCSQ(pcSubStr, pCaseSensitive)
			return This.FindPositionsCSQR(pcSubStr, pCaseSensitive, :stzList)
				
		def FindPositionsCSQR(pcSubStr, pCaseSensitive, pcReturnType)
			return This.FindCSQR(pcSubStr, pCaseSensitive, pcReturnType)

	#-- WITHOUT CASESENSITIVITY

	def FindAll(pcSubStr)
		return This.Find(pcSubStr)

		def FindAllQ(pcSubStr)
			return This.FindAllQR(pcSubStr, :stzList)
			
		def FindAllQR(pcSubStr, pcReturnType)
			return This.FindQR(pcSubStr, pcReturnType)

	def FindSubString(pcSubStr)
		return This.Find(pcSubStr)

		def FindSubStringQ(pcSubStr)
			return This.FindSubStringQR(pcSubStr, :stzList)
			
		def FindSubStringQR(pcSubStr, pcReturnType)
			return This.FindQR(pcSubStr, pcReturnType)

	def Occurrences(pcSubStr)
		return This.Find(pcSubStr)

		def OccurrencesQ(pcSubStr)
			return This.OccurrencesQR(pcSubStr, :stzList)
			
		def OccurrencesQR(pcSubStr, pcReturnType)
			return This.FindQR(pcSubStr, pcReturnType)

	def Positions(pcSubStr)
		return This.Find(pcSubStr)

		def PositionsQ(pcSubStr)
			return This.PositionsQR(pcSubStr, :stzList)
			
		def PositionsQR(pcSubStr, pcReturnType)
			return This.FindQR(pcSubStr, pcReturnType)

	def PositionsOfSubString(pcSubStr)
		return This.Find(pcSubStr)

		def PositionsOfSubStringQ(pcSubStr)
			return This.PositionsOfSubStringQR(pcSubStr, :stzList)
			
		def PositionsOfSubStringQR(pcSubStr, pcReturnType)
			return This.FindQR(pcSubStr, pcReturnType)

	def FindPositions(pcSubStr)
		return This.Find(pcSubStr)

		def FindPositionsQ(pcSubStr)
			return This.FindPositionsQR(pcSubStr, :stzList)
			
		def FindPositionsQR(pcSubStr, pcReturnType)
			return This.FindQR(pcSubStr, pcReturnType)

	def FindOccurrences(pcSubStr)
		if isList(pcSubStr) and
		   Q(pcSubStr).IsOneOfTheseNamedParams([ :Of, :OfSubString ])
			pcSubStr = pcSubStr[2]
		ok

		return This.Find(pcSubStr)

		def FindOccurrencesQ(pcSubStr)
			return This.FindOccurrencesQR(pcSubStr, :stzList)
			
		def FindOccurrencesQR(pcSubStr, pcReturnType)
			return This.FindAllQR(pcSubStr, pcReturnType)

	  #------------------------------#
	 #  ALTERNATIVES OF FindMany()  #
	#------------------------------#

	def FindManySubStringsCS(pacSubStr, pCaseSensitive)
		return This.FindManyCS(pacSubStr, pCaseSensitive)

		def FindManySubStringsCSQ(pacSubStr, pCaseSensitive)
			return This.FindManyCSQ(pacSubStr, pCaseSensitive)
		
		def FindManySubStringsCSQR(pacSubStr, pCaseSensitive, pcReturnType)
			return This.FindManyCSQR(pacSubStr, pCaseSensitive, pcReturnType)

	def FindTheseSubStringsCS(pacSubStr, pCaseSensitive)
		return This.FindManyCS(pacSubStr, pCaseSensitive)

		def FindTheseSubStringsCSQ(pacSubStr, pCaseSensitive)
			return This.FindManyCSQ(pacSubStr, pCaseSensitive)
		
		def FindTheseSubStringsCSQR(pacSubStr, pCaseSensitive, pcReturnType)
			return This.FindManyCSQR(pacSubStr, pCaseSensitive, pcReturnType)

	#-- WITHOUT CASESENSITIVITY

	def FindManySubStrings(pacSubStr)
		return This.FindMany(pacSubStr)

		def FindManySubStringsQ(pacSubStr)
			return This.FindManyQ(pacSubStr)
		
		def FindManySubStringsQR(pacSubStr, pcReturnType)
			return This.FindManyQR(pacSubStr, pcReturnType)

	def FindTheseSubStrings(pacSubStr)
		return This.FindMany(pacSubStr)

		def FindTheseSubStringsQ(pacSubStr)
			return This.FindManyQ(pacSubStr)
		
		def FindTheseSubStringsQR(pacSubStr, pcReturnType)
			return This.FindManyQR(pacSubStr, pcReturnType)

	  #----------------------------------------#
	 #  ALTERNATIVES OF FindManyAsSections()  #
	#----------------------------------------#

	def FindSubStringsAsSectionsCS(pacSubStr, pCaseSensitive)
		return This.FindManyAsSectionsCS(pacSubStr, pCaseSensitive)

	def FindTheseSubStringsAsSectionsCS(pacSubStr, pCaseSensitive)
		return This.FindManyAsSectionsCS(pacSubStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringsAsSections(pacSubStr)
		return This.FindManyAsSections(pacSubStr)

	def FindTheseSubStringsAsSections(pacSubStr)
		return This.FindManyAsSections(pacSubStr)

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

	  #--------------------------------#
	 #  ALTERNATIVES OF FindManyXT()  #
	#--------------------------------#

	def TheseSubStringsAndTheirPositionsCS(pacSubStr, pCaseSensitive)
		return This.FindManyXTCS(pacSubStr, pCaseSensitive)

		def TheseSubStringsAndTheirPositionsCSQ(pCaseSensitive)
			return This.FindManyXTCSQ(pacSubStr, pCaseSensitive)

		def TheseSubStringsAndTheirPositionsCSQR(pacSubStr, pcReturnType)
			return This.FindManyXTCSQR(pacSubStr, pCaseSensitive, pcReturnType)

	#--

	def TheseSubStringsAndTheirPositions(pacSubStr)
		return This.FindManyXT(pacSubStr)

		def TheseSubStringsAndTheirPositionsQ(pacSubStr)
			return This.FindManyXTQ(pacSubStr)

		def TheseSubStringsAndTheirPositionsQR(pacSubStr, pcReturnType)
			return This.FindManyXTQR(pacSubStr, pcReturnType)

	  #---------------------------------#
	 #  ALTERNATIVES OF FindManyXTT()  #
	#---------------------------------#

	def TheseSubStringsAndTheirSectionsCS(pacSubStr, pCaseSensitive)
		return This.FindManyXTTCS(pacSubStr, pCaseSensitive)

		def TheseSubStringsAndTheirSectionsCSQ(pacSubStr, pCaseSensitive)
			return This.FindManyXTTCSQ(pacSubStr, pCaseSensitive)

		def TheseSubStringsAndTheirSectionsCSQR(pacSubStr, pcReturnType)
			return This.FindManyXTTCSQR(pacSubStr, pCaseSensitive, pcReturnType)

	#-- WITHOUT CASESENSITIVITY

	def TheseSubStringsAndTheirSections(pacSubStr)
		return This.FindManyXTT(pacSubStr)

		def TheseSubStringsAndTheirSectionsQ(pacSubStr)
			return This.FindManyXTTQ(pacSubStr)

		def TheseSubStringsAndTheirSectionsQR(pacSubStr, pcReturnType)
			return This.FindManyXTTQR(pacSubStr, pcReturnType)

	  #------------------------------------#
	 #  ALTERNATIVES OF FindAsSections()  #
	#------------------------------------#

	def FindSubStringAsSectionsCS(pcSubStr, pCaseSensitive)
		return This.FindAsSectionsCS(pcSubStr, pCaseSensitive)

		def FindSubStringAsSectionsCSQ(pcSubStr, pCaseSensitive)
			return This.FindAsSectionsCSQ(pcSubStr, pCaseSensitive)

		def FindSubStringAsSectionsCSQR(pcSubStr, pCaseSensitive, pcReturnType)
			return This.FindAsSectionsCSQR(pcSubStr, pCaseSensitive, pcReturnType)

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringAsSections(pcSubStr)
		return This.FindAsSections(pcSubStr)

		def FindSubStringAsSectionsQ(pcSubStr)
			return This.FindAsSectionsQ(pcSubStr)

		def FindSubStringAsSectionsQR(pcSubStr, pcReturnType)
			return This.FindAsSectionsQR(pcSubStr, pcReturnType)

	  #----------------------------------------------#
	 #  ALTERNATIVES OF FindThisSubStringBetween()  #
	#----------------------------------------------#

	def FindThisSubStringBetweenAsSectionsQ(pcSubStr, pcBound1, pcBound2)
		return This.FindSubstringBetweenAsSectionsQ(pcSubStr, pcBound1, pcbound2)
		
	def FindThisSubStringBetweenAsSectionsQR(pcSubStr, pcBound1, pcBound2, pcReturnType)
		return This.FindSubstringBetweenAsSectionsQR(pcSubStr, pcBound1, pcbound2, pcReturnType)
	
	def FindSubstringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindThisSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindSubstringBetweenCSQ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindSubstringBetweenCSQR(pcSubStr, pcBound1, pcBound2, pCaseSensitive, :stzList)

		def FindSubstringBetweenCSQR(pcSubStr, pcBound1, pcBound2, pCaseSensitive, pcReturnType)
			return This.FindThisSubStringBetweenCSQR(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE, pcReturnType)			

	def FindThisBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindThisBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindThisBetweenCSQ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindThisBetweenCSQR(pcSubStr, pcBound1, pcBound2, pCaseSensitive, :stzList)

		def FindThisBetweenCSQR(pcSubStr, pcBound1, pcBound2, pCaseSensitive, pcReturnType)
			return This.FindThisSubStringBetweenCSQR(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE, pcReturnType)			

	#--

	def FindThisSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
		return This.FindThisSubStringBetweenByCS(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

		def FindThisSubStringBoundedByCSQ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindThisSubStringBoundedByCSQR(pcSubStr, pacBounds, pCaseSensitive, :stzList)

		def FindThisSubStringBoundedByCSQR(pcSubStr, pacBounds, pCaseSensitive, pcReturnType)
			return This.FindThisSubStringBoundedByCSQR(pcSubStr, pacBounds, :CaseSensitive = TRUE, pcReturnType)			

	def FindSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
		return This.FindThisSubStringBetweenByCS(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

		def FindSubstringBoundedByCSQ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubstringBoundedByCSQR(pcSubStr, pacBounds, pCaseSensitive, :stzList)

		def FindSubstringBoundedByCSQR(pcSubStr, pacBounds, pCaseSensitive, pcReturnType)
			return This.FindThisSubStringBoundedByCSQR(pcSubStr, pacBounds, :CaseSensitive = TRUE, pcReturnType)			

	def FindThisBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
		return This.FindThisSubStringBetweenByCS(pcSubStr, pacBounds, pCaseSensitive)

		def FindThisBoundedByCSQ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindThisBoundedByCSQR(pcSubStr, pacBounds, pCaseSensitive, :stzList)

		def FindThisBoundedByCSQR(pcSubStr, pacBounds, pCaseSensitive, pcReturnType)
			return This.FindThisSubStringBoundedByCSQR(pcSubStr, pacBounds, :CaseSensitive = TRUE, pcReturnType)			

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetween(pcSubStr, pcBound1, pcBound2)
		return This.FindThisSubStringBetween(pcSubStr, pcBound1, pcBound2)

		def FindSubstringBetweenQ(pcSubStr, pcBound1, pcBound2)
			return This.FindSubstringBetweenQR(pcSubStr, pcBound1, pcBound2, :stzList)

		def FindSubstringBetweenQR(pcSubStr, pcBound1, pcBound2, pcReturnType)
			return This.FindThisSubStringBetweenQR(pcSubStr, pcBound1, pcBound2, pcReturnType)			

	def FindThisBetween(pcSubStr, pcBound1, pcBound2)
		return This.FindSubStringBetween(pcSubStr, pcBound1, pcBound2)

		def FindThisBetweenQ(pcSubStr, pcBound1, pcBound2)
			return This.FindThisBetweenQR(pcSubStr, pcBound1, pcBound2, :stzList)

		def FindThisBetweenQR(pcSubStr, pcBound1, pcBound2, pcReturnType)
			return This.FindThisSubStringBetweenQR(pcSubStr, pcBound1, pcBound2, pcReturnType)			

	#--

	def FindThisSubStringBoundedBy(pcSubStr, pacBounds)
		return This.FindThisSubStringBetweenBy(pcSubStr, pacBounds[1], pacBounds[2])

		def FindThisSubStringBoundedByQ(pcSubStr, pacBounds)
			return This.FindThisSubStringBoundedByQR(pcSubStr, pacBounds, pCaseSensitive, :stzList)

		def FindThisSubStringBoundedByQR(pcSubStr, pacBounds, pCaseSensitive, pcReturnType)
			return This.FindThisSubStringBoundedByQR(pcSubStr, pacBounds, :CaseSensitive = TRUE, pcReturnType)			

	def FindSubStringBoundedBy(pcSubStr, pacBounds)
		return This.FindThisSubStringBetweenBy(pcSubStr, pacBounds[1], pacBounds[2])

		def FindSubstringBoundedByQ(pcSubStr, pacBounds)
			return This.FindSubstringBoundedByQR(pcSubStr, pacBounds, pCaseSensitive, :stzList)

		def FindSubstringBoundedByQR(pcSubStr, pacBounds, pCaseSensitive, pcReturnType)
			return This.FindThisSubStringBoundedByQR(pcSubStr, pacBounds, :CaseSensitive = TRUE, pcReturnType)			

	def FindThisBoundedBy(pcSubStr, pacBounds)
		return This.FindThisSubStringBetweenBy(pcSubStr, pacBounds)

		def FindThisBoundedByQ(pcSubStr, pacBounds)
			return This.FindThisBoundedByQR(pcSubStr, pacBounds, pCaseSensitive, :stzList)

		def FindThisBoundedByQR(pcSubStr, pacBounds, pCaseSensitive, pcReturnType)
			return This.FindThisSubStringBoundedByQR(pcSubStr, pacBounds, :CaseSensitive = TRUE, pcReturnType)			

	  #-----------------------------------------------#
	 #  ALTERNATIVES OF NumberOfOccurrenceBetween()  #
	#-----------------------------------------------#

	def FindThisBetweenAsSectionsCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindSubstringBetweenAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		
		def FindThisBetweenAsSectionsCSQ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindSubstringBetweenAsSectionsCSQ(pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		
		def FindThisBetweenAsSectionsCSQR(pcSubStr, pcBound1, pcBound2, pCaseSensitive, pcReturnType)
			return This.FindSubstringBetweenAsSectionsCSQR(pcSubStr, pcBound1, pcbound2, pCaseSensitive, pcReturnType)

	def FindThisSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindSubstringBetweenAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		
		def FindThisSubStringBetweenAsSectionsCSQ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindSubstringBetweenAsSectionsCSQ(pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		
		def FindThisSubStringBetweenAsSectionsCSQR(pcSubStr, pcBound1, pcBound2, pCaseSensitive, pcReturnType)
			return This.FindSubstringBetweenAsSectionsCSQR(pcSubStr, pcBound1, pcbound2, pCaseSensitive, pcReturnType)

	#-- WITHOUT CASESENSITIVITY

	def FindThisBetweenAsSections(pcSubStr, pcBound1, pcBound2)
		return This.FindSubstringBetweenAsSections(pcSubStr, pcBound1, pcbound2)
		
		def FindThisBetweenAsSectionsQ(pcSubStr, pcBound1, pcBound2)
			return This.FindSubstringBetweenAsSectionsQ(pcSubStr, pcBound1, pcbound2)
		
		def FindThisBetweenAsSectionsQR(pcSubStr, pcBound1, pcBound2, pcReturnType)
			return This.FindSubstringBetweenAsSectionsQR(pcSubStr, pcBound1, pcbound2, pcReturnType)

	def FindThisSubStringBetweenAsSections(pcSubStr, pcBound1, pcBound2)
		return This.FindSubstringBetweenAsSections(pcSubStr, pcBound1, pcbound2)

	  #-----------------------------------------------#
	 #  ALTERNATIVES OF NumberOfOccurrenceBetween()  #
	#-----------------------------------------------#

	def NumberOfOccurrencesBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

	def NumberOfSectionsBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

	def CountBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

	def HaowManyBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrencesBetween(pcSubStr, pcBound1, pcBound2)
		return This.NumberOfOccurrenceBetween(pcSubStr, pcBound1, pcBound2)

	def NumberOfSectionsBetween(pcSubStr, pcBound1, pcBound2)
		return This.NumberOfOccurrenceBetween(pcSubStr, pcBound1, pcBound2)

	def CountBetween(pcSubStr, pcBound1, pcBound2)
		return This.NumberOfOccurrenceBetween(pcSubStr, pcBound1, pcBound2)

	def HowManyBetween(pcSubStr, pcBound1, pcBound2)
		return This.NumberOfOccurrenceBetween(pcSubStr, pcBound1, pcBound2)

	  #------------------------------------------#
	 #  ALTERNATIVES OF NumberOfOccurrenceXT()  #
	#------------------------------------------#

	def NumberOfOccurrencesXTCS(pcSubStr, pacBetween, pCaseSensitive)
		return This.NumberOfOccurrenceXTCS(pcSubStr, pacBetween, pCaseSensitive)

	def NumberOfOccurrenceOfSubstringXTCS(pcSubStr, pacBetween, pCaseSensitive)
		return This.NumberOfOccurrenceXTCS(pcSubStr, pacBetween, pCaseSensitive)

	def NumberOfOccurrencesOfSubstringXTCS(pcSubStr, pacBetween, pCaseSensitive)
		return This.NumberOfOccurrenceXTCS(pcSubStr, pacBetween, pCaseSensitive)

	def CountXTCS(pcSubStr, pacBetween, pCaseSensitive)
		return This.NumberOfOccurrenceXTCS(pcSubStr, pacBetween, pCaseSensitive)

	def HowManyXTCS(pcSubStr, pacBetween, pCaseSensitive)
		return This.NumberOfOccurrenceXTCS(pcSubStr, pacBetween, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrencesXT(pcSubStr, pacBetween)
		return This.NumberOfOccurrenceXT(pcSubStr, pacBetween)

	def NumberOfOccurrenceOfSubstringXT(pcSubStr, pacBetween)
		return This.NumberOfOccurrenceXT(pcSubStr, pacBetween)

	def NumberOfOccurrencesOfSubstringXT(pcSubStr, pacBetween)
		return This.NumberOfOccurrenceXT(pcSubStr, pacBetween)

	def CountXT(pcSubStr, pacBetween)
		return This.NumberOfOccurrenceXT(pcSubStr, pacBetween)

	def HowManyXT(pcSubStr, pacBetween)
		return This.NumberOfOccurrenceXT(pcSubStr, pacBetween)

	  #-----------------------------------------#
	 #  ALTERNATIVES OF NumberOfOccurrenceW()  #
	#-----------------------------------------#

	def CountW(pcCondition, pCaseSensitive)
		return This.NumberOfOccurrenceW(pcCondition, pCaseSensitive)

	def HowManyW(pcCondition, pCaseSensitive)
		return This.NumberOfOccurrenceW(pcCondition, pCaseSensitive)

	  #---------------------------------#
	 #  ALTERNATIVES OF FindBetween()  #
	#---------------------------------#

	def FindSubStringsBetweenCS(pcBound1, pcBound2, pCaseSensitive)
		return This.FindBetweenCS(pcBound1, pcBound2, pCaseSensitive)

	def FindSubStringsBoundedByCS(pcBound1, pcBound2, pCaseSensitive)
		return This.FindBoundedByCS(pcBound1, pcBound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringsBetween(pcBound1, pcBound2)
		return This.FindBetween(pcBound1, pcBound2)

	def FindSubStringsBoundedBy(pcBound1, pcBound2)
		return This.FindBoundedByAsSections(pcBound1, pcBound2)

	  #-----------------------------------------#
	 #  ALTERNATIVES OF FindBetweenSections()  #
	#-----------------------------------------#

	def FindSubStringsBetweenAsSectionsCS(pcBound1, pcBound2, pCaseSensitive)
		return This.FindBetweenAsSectionsCS(pcBound1, pcBound2, pCaseSensitive)

	def FindSubStringsBoundedByAsSectionsCS(pcBound1, pcBound2, pCaseSensitive)
		return This.FindBoundedByAsSectionsCS(pcBound1, pcBound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringsBetweenAsSections(pcBound1, pcBound2)
		return This.FindBetweenAsSections(pcBound1, pcBound2)

	def FindSubStringsBoundedByAsSections(pcBound1, pcBound2)
		return This.FindBoundedByAsSections(pcBound1, pcBound2)

	  #-------------------------------------------------------#
	 #  ALTERNATIVES OF FindNthSubStringBetweenAsSections()  #
	#-------------------------------------------------------#

	def FindNthBetweenAsSectionsCS(n, pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		return This.FindNthSubStringBetweenAsSectionsCS(n, pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		
	def FindNthSubStringBoundedByAsSectionsCS(n, pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		return This.FindNthSubStringBetweenAsSectionsCS(n, pcSubStr, pcBound1, pcbound2, pCaseSensitive)

	def FindNthBoundedByAsSectionsCS(n, pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		return This.FindNthSubStringBetweenAsSectionsCS(n, pcSubStr, pcBound1, pcbound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindNthBetweenAsSections(n, pcSubStr, pcBound1, pcbound2)
		return This.FindNthSubStringBetweenAsSections(n, pcSubStr, pcBound1, pcbound2)
		
	def FindNthSubStringBoundedByAsSections(n, pcSubStr, pcBound1, pcbound2)
		return This.FindNthSubStringBetweenAsSections(n, pcSubStr, pcBound1, pcbound2)

	def FindNthBoundedByAsSections(n, pcSubStr, pcBound1, pcbound2)
		return This.FindNthSubStringBetweenAsSections(n, pcSubStr, pcBound1, pcbound2)

	  #---------------------------------------------------------#
	 #  ALTERNATIVES OF FindFirstSubStringBetweenAsSections()  #
	#---------------------------------------------------------#

	def FindFirstBetweenAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		return This.FindFirstSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		
	def FindFirstSubStringBoundedByAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		return This.FindFirstSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive)

	def FindFirstBoundedByAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		return This.FindFirstSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstBetweenAsSections(pcSubStr, pcBound1, pcbound2)
		return This.FindFirstSubStringBetweenAsSections(pcSubStr, pcBound1, pcbound2)
		
	def FindFirstSubStringBoundedByAsSections(pcSubStr, pcBound1, pcbound2)
		return This.FindFirstSubStringBetweenAsSections(pcSubStr, pcBound1, pcbound2)

	def FindFirstBoundedByAsSections(pcSubStr, pcBound1, pcbound2)
		return This.FindFirstSubStringBetweenAsSections(pcSubStr, pcBound1, pcbound2)

	  #--------------------------------------------------------#
	 #  ALTERNATIVES OF FindLastSubStringBetweenAsSections()  #
	#--------------------------------------------------------#

	def FindLastBetweenAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		return This.FindLastSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		
	def FindLastSubStringBoundedByAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		return This.FindLastSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive)

	def FindLastBoundedByAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		return This.FindLastSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastBetweenAsSections(pcSubStr, pcBound1, pcbound2)
		return This.FindLastSubStringBetweenAsSections(pcSubStr, pcBound1, pcbound2)
		
	def FindLastSubStringBoundedByAsSections(pcSubStr, pcBound1, pcbound2)
		return This.FindLastSubStringBetweenAsSections(pcSubStr, pcBound1, pcbound2)

	def FindLastBoundedByAsSections(pcSubStr, pcBound1, pcbound2)
		return This.FindLastSubStringBetweenAsSections(pcSubStr, pcBound1, pcbound2)

	  #-----------------------------------#
	 #  ALTERNATIVES OF FindBetweenIB()  #
	#-----------------------------------#

	def FindNthBetweenAsSectionsIBCS(n, pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		return This.FindNthSubStringBetweenAsSectionsIBCS(n, pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		
	def FindNthSubStringBoundedByAsSectionsIBCS(n, pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		return This.FindNthSubStringBetweenAsSectionsIBCS(n, pcSubStr, pcBound1, pcbound2, pCaseSensitive)

	def FindNthBoundedByAsSectionsIBCS(n, pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		return This.FindNthSubStringBetweenAsSectionsIBCS(n, pcSubStr, pcBound1, pcbound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindNthBetweenAsSectionsIB(n, pcSubStr, pcBound1, pcbound2)
		return This.FindNthSubStringBetweenAsSectionsIB(n, pcSubStr, pcBound1, pcbound2)
		
	def FindNthSubStringBoundedByAsSectionsIB(n, pcSubStr, pcBound1, pcbound2)
		return This.FindNthSubStringBetweenAsSectionsIB(n, pcSubStr, pcBound1, pcbound2)

	def FindNthBoundedByAsSectionsIB(n, pcSubStr, pcBound1, pcbound2)
		return This.FindNthSubStringBetweenAsSectionsIB(n, pcSubStr, pcBound1, pcbound2)

	  #-----------------------------------#
	 #  ALTERNATIVES OF FindBetweenIB()  #
	#-----------------------------------#

	def FindSubStringsBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)
		return This.FindBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)

	def FindSubStringsBoundedByIBCS(pcBound1, pcBound2, pCaseSensitive)
		return This.FindBoundedByIBCS(pcBound1, pcBound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringsBetweenIB(pcBound1, pcBound2)
		return This.FindBetweenIB(pcBound1, pcBound2)

	def FindSubStringsBoundedByIB(pcBound1, pcBound2)
		return This.FindBoundedByIB(pcBound1, pcBound2)

	  #-----------------------------------------------#
	 #  ALTERNATIVES OF FindBoundedByAsSectionsIB()  #
	#-----------------------------------------------#

	def FindSubStringsBetweenAsSectionsIBCS(pcBound1, pcBound2, pCaseSensitive)
		return This.FindBetweenAsSectionsIBCS(pcBound1, pcBound2, pCaseSensitive)

	def FindSubStringsBoundedByAsSectionsIBCS(pcBound1, pcBound2, pCaseSensitive)
		return This.FindBoundedByAsSectionsIBCS(pcBound1, pcBound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringsBetweenAsSectionsIB(pcBound1, pcBound2)
		return This.FindBetweenAsSectionsIB(pcBound1, pcBound2)

	def FindSubStringsBoundedByAsSectionsIB(pcBound1, pcBound2)
		return This.FindBoundedByAsSectionsIB(pcBound1, pcBound2)

	  #----------------------------------------------#
	 #  ALTERNATIVES OF RemoveSubStringBetweenIB()  #
	#----------------------------------------------#

	def RemoveThisBetweenIBCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		This.RemoveSubStringBetweenIBCS(pcSubStr,pcBound1, pcBound2, pCaseSensitive)

		def RemoveThisBetweenIBCSQ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			This.RemoveThisBetweenIBCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveThisSubStringBetweenIBCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		This.RemoveSubStringBetweenIBCS(pcSubStr,pcBound1, pcBound2, pCaseSensitive)

		def RemoveThisSubStringBetweenIBCSQ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			This.RemoveThisBetweenIBCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveThisSubStringBoundedByIBCS(pcSubStr, pacBounds, pCaseSensitive)
		This.RemoveSubStringBetweenIBCS(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

		def RemoveThisSubStringBoundedByIBCSQ(pcSubStr, pacBounds, pCaseSensitive)
			This.RemoveThisSubStringBoundedByIBCS(pcSubStr, pacBounds, pCaseSensitive)
			return This

	#--

	def RemoveSubStringBoundedByIBCS(pcSubStr, pacBounds, pCaseSensitive)
		This.RemoveSubStringBetweenIBCS(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

		def RemoveSubStringBoundedByIBCSQ(pcSubStr, pacBounds, pCaseSensitive)
			This.RemoveSubStringBoundedByIBCS(pcSubStr, pacBounds, pCaseSensitive)
			return This

	#-- WITHOUT CASESENSITIVITY

	def RemoveThisBetweenIB(pcSubStr, pcBound1, pcBound2)
		This.RemoveSubStringBetweenIB(pcSubStr,pcBound1, pcBound2)

		def RemoveThisBetweenIBQ(pcSubStr, pcBound1, pcBound2)
			This.RemoveThisBetweenIB(pcSubStr, pcBound1, pcBound2)
			return This

	def RemoveThisSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)
		This.RemoveSubStringBetweenIB(pcSubStr,pcBound1, pcBound2)

		def RemoveThisSubStringBetweenIBQ(pcSubStr, pcBound1, pcBound2)
			This.RemoveThisBetweenIB(pcSubStr, pcBound1, pcBound2)
			return This

	def RemoveThisSubStringBoundedByIB(pcSubStr, pacBounds)
		This.RemoveSubStringBetweenIB(pcSubStr, pacBounds[1], pacBounds[2])

		def RemoveThisSubStringBoundedByIBQ(pcSubStr, pacBounds)
			This.RemoveThisSubStringBoundedByIB(pcSubStr, pacBounds)
			return This

	#--

	def RemoveSubStringBoundedByIB(pcSubStr, pacBounds)
		This.RemoveSubStringBetweenIB(pcSubStr, pacBounds[1], pacBounds[2])

		def RemoveSubStringBoundedByIBQ(pcSubStr, pacBounds)
			This.RemoveSubStringBoundedByIB(pcSubStr, pacBounds)
			return This

	  #-----------------------------------#
	 #  ALTERNATIVES OF NthBetweenIBZ()  #
	#-----------------------------------#

	def NthSubStringBetweenIBZCS(n, pcBound1, pcBound2, pCaseSensitive)
		return This.NthBetweenIBZCS(n, pcBound1, pcBound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NthSubStringBetweenIBZ(n, pcBound1, pcBound2)
		return This.NthBetweenIBZ(n, pcBound1, pcBound2)

	  #------------------------------------#
	 #  ALTERNATIVES OF NthBetweenIBZZ()  #
	#------------------------------------#

	def NthSubStringBetweenIBZZCS(n, pcBound1, pcBound2, pCaseSensitive)
		return This.NthBetweenIBZZCS(n, pcBound1, pcBound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NthSubStringBetweenIBZZ(n, pcBound1, pcBound2)
		return This.NthBetweenIBZZ(n, pcBound1, pcBound2)

	  #----------------------------------#
	 #  ALTERNATIVES OF NthBetweenIB()  #
	#----------------------------------#
	
	def NthSubStringBetweenIBCS(n, pcBound1, pcBound2, pCaseSensitive)
		return This.NthBetweenIBCS(n, pcBound1, pcBound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NthSubStringBetweenIB(n, pcBound1, pcBound2)
		return This.NthBetweenIB(n, pcBound1, pcBound2)

	  #----------------------------------#
	 #  ALTERNATIVES OF NthBetweenZZ()  #
	#----------------------------------#

	def NthSubStringBetweenZZCS(n, pcBound1, pcBound2, pCaseSensitive)
		return This.NthBetweenZZCS(n, pcBound1, pcBound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NthSubStringBetweenZZ(n, pcBound1, pcBound2)
		return This.NthBetweenZZ(n, pcBound1, pcBound2)


	  #---------------------------------#
	 #  ALTERNATIVES OF NthBetweenZ()  #
	#---------------------------------#

	def NthSubStringBetweenZCS(n, pcBound1, pcBound2, pCaseSensitive)
		return This.NthBetweenZCS(n, pcBound1, pcBound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NthSubStringBetweenZ(n, pcBound1, pcBound2)
		return This.NthBetweenZ(n, pcBound1, pcBound2)

	  #--------------------------------#
	 #  ALTERNATIVES OF NthBetween()  #
	#--------------------------------#

	def NthSubStringBetweenCS(n, pcBound1, pcBound2, pCaseSensitive)
		return This.NthBetweenCS(n, pcBound1, pcBound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NthSubStringBetween(n, pcBound1, pcBound2)
		return This.NthBetween(n, pcBound1, pcBound1)


	  #-------------------------------------------------#
	 #  ALTERNATIVES OF NumberOfSubStringsBoundedBy()  #
	#-------------------------------------------------#

	def CountSubStringsBoundedByCS(pacBounds, pCaseSensitive)
		return This.NumberOfSubStringsBoundedByCS(pacBounds, pCaseSensitive)

	def HowManySubStringsBoundedByCS(pacBounds, pCaseSensitive)
		return This.NumberOfSubStringsBoundedByCS(pacBounds, pCaseSensitive)

	def NumberOfSubStringsBetweenCS(pcBound1, pcBound2, pCaseSensitive)
		if isList(pcBound2) and Q(pcBound2).IsAndNamedParam()
			pcBound2 = pcBound2[2]
		ok

		return This.NumberOfSubStringsBoundedByCS(pacBounds[1], pacBounds[2], pCaseSensitive)

	def CountSubStringsBetweenCS(pcBound1, pcBound2, pCaseSensitive)
		return This.NumberOfSubStringsBetweenCS(pcBound1, pcBound2, pCaseSensitive)

	def HowManySubStringsBetweenCS(pcBound1, pcBound2, pCaseSensitive)
		return This.NumberOfSubStringsBetweenCS(pcBound1, pcBound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def CountSubStringsBoundedBy(pacBounds)
		return This.NumberOfSubStringsBoundedBy(pacBounds)

	def HowManySubStringsBoundedBy(pacBounds)
		return This.NumberOfSubStringsBoundedBy(pacBounds)

	#--

	def NumberOfSubStringsBetween(pcBound1, pcBound2)
		if isList(pcBound2) and Q(pcBound2).IsAndNamedParam()
			pcBound2 = pcBound2[2]
		ok

		return This.NumberOfSubStringsBoundedBy(pacBounds[1], pacBounds[2])

	def CountSubStringsBetween(pcBound1, pcBound2)
		return This.NumberOfSubStringsBetween(pcBound1, pcBound2)

	def HowManySubStringsBetween(pcBound1, pcBound2)
		return This.NumberOfSubStringsBetweenCS(pcBound1, pcBound2)

	  #----------------------------------------#
	 #  ALTERNATIVES OF SubstringsBetweenU()  #
	#----------------------------------------#

	def UniqueSubStringsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		return This.SubstringsBetweenUCS(pcSubStr1, pcSubStr2, pCaseSensitive)

	#--

	def UniqueSubStringsBoundedByCS(pacBounds, pCaseSensitive)
		return This.SubstringsBetweenUCS(pacBounds[1], pacBounds[2], pCaseSensitive, :stzList)

		def UniqueSubStringsBoundedByCSQ(pacBounds, pCaseSensitive)
			return This.SubstringsBetweenUCSQ(pacBounds[1], pacBounds[2], pCaseSensitive)

		def UniqueSubstringsBoundedByCSQR(pacBounds, pCaseSensitive, pcReturnType)
			return This.SubstringsBetweenUCSQR(pacBounds[1], pacBounds[2], pCaseSensitive, pcReturnType)

	#--

	def UniqueSectionsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		return This.SubstringsBetweenUCS(pcSubStr1, pcSubStr2, pCaseSensitive)

		def UniqueSectionsBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBetweenUCSQ(ppacBounds[1], pacBounds[2], pCaseSensitive)

		def UniqueSectionsBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
			return This.SubstringsBetweenUCSQR(pacBounds[1], pacBounds[2], pCaseSensitive, pcReturnType)

	def UniqueSectionsBoundedByCS(pacBounds, pCaseSensitive)
		return This.SubstringsBetweenUCS(pacBounds[1], pacBounds[2], pCaseSensitive)

		def UniqueSectionsBoundedByCSQ(pacBounds, pCaseSensitive)
			return This.SubstringsBetweenUCSQ(pacBounds[1], pacBounds[2], pCaseSensitive)

		def UniqueSectionsBoundedByCSQR(pacBounds, pCaseSensitive, pcReturnType)
			return This.SubstringsBetweenUCSQR(pacBounds[1], pacBounds[2], pCaseSensitive, pcReturnType)

	#==

	def SubStringsBoundedByUCS(pacBounds, pCaseSensitive)
		return This.SubstringsBetweenUCS(pacBounds[1], pacBounds[2], pCaseSensitive, :stzList)

		def SubStringsBoundedByUCSQ(pacBounds, pCaseSensitive)
			return This.SubstringsBetweenUCSQ(pacBounds[1], pacBounds[2], pCaseSensitive)

		def SubstringsBoundedByUCSQR(pacBounds, pCaseSensitive, pcReturnType)
			return This.SubstringsBetweenUCSQR(pacBounds[1], pacBounds[2], pCaseSensitive, pcReturnType)

	#--

	def SectionsBetweenUCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		return This.SubstringsBetweenUCS(pcSubStr1, pcSubStr2, pCaseSensitive)

		def SectionsBetweenUCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBetweenUCSQ(ppacBounds[1], pacBounds[2], pCaseSensitive)

		def USectionsBetweenUCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
			return This.SubstringsBetweenUCSQR(pacBounds[1], pacBounds[2], pCaseSensitive, pcReturnType)

	def SectionsBoundedByUCS(pacBounds, pCaseSensitive)
		return This.SubstringsBetweenUCS(pacBounds[1], pacBounds[2], pCaseSensitive)

		def SectionsBoundedByUCSQ(pacBounds, pCaseSensitive)
			return This.SubstringsBetweenUCSQ(pacBounds[1], pacBounds[2], pCaseSensitive)

		def SectionsBoundedByUCSQR(pacBounds, pCaseSensitive, pcReturnType)
			return This.SubstringsBetweenUCSQR(pacBounds[1], pacBounds[2], pCaseSensitive, pcReturnType)

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





