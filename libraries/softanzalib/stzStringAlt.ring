
func StzStringAltQ(pcStr)
	return new stzStringAlt(pcStr)

class stzStringAlt from stzString

	  #--------------------------------#
	 #  ALTERNATIVES OF SubStrings()  #
	#--------------------------------#

	def AllSubStringsCS(pCaseSitive)
		return This.SubStringsCS(pCaseSitive)

		def AllSubStringsCSQ(pCaseSitive)
			return This.SubStringsCSQ(pCaseSitive)

		def AllSubStringsCSQR(pCaseSitive, pcReturnType)
			return This.SubStringsCSQR(pCaseSitive, pcReturnType)

	def AllPossibleSubStringsCS(pCaseSitive)
		return This.SubStringsCS(pCaseSitive)

		def AllPossibleSubStringsCSQ(pCaseSitive)
			return This.SubStringsCSQ(pCaseSitive)

		def AllPossibleSubStringsCSQR(pCaseSitive, pcReturnType)
			return This.SubStringsCSQR(pCaseSitive, pcReturnType)

	def PossibleSubStringsCS(pCaseSitive)
		return This.SubStringsCS(pCaseSitive)

		def PossibleSubStringsCSQ(pCaseSitive)
			return This.SubStringsCSQ(pCaseSitive)

		def PossibleSubStringsCSQR(pCaseSitive, pcReturnType)
			return This.SubStringsCSQR(pCaseSitive, pcReturnType)

	#-- WITHOUT CASESENSITIVE

	def AllSubStrings()
		return This.SubStrings()

		def AllSubStringsQ()
			return This.SubStringsQ()

		def AllSubStringsQR(pcReturnType)
			return This.SubStringsQR(pcReturnType)

	def AllPossibleSubStrings()
		return This.SubStrings()

		def AllPossibleSubStringsQ()
			return This.SubStringsQ()

		def AllPossibleSubStringsQR(pcReturnType)
			return This.SubStringsQR(pcReturnType)

	def PossibleSubStrings()
		return This.SubStrings()

		def PossibleSubStringsQ()
			return This.SubStringsQ()

		def PossibleSubStringsQR(pcReturnType)
			return This.SubStringsQR(pcReturnType)

	  #----------------------------#
	 #  ALTERNATIVES OF Append()  #
	#----------------------------#

	def Add(pcOtherStr)
		This.Append(pcOtherStr)

		def AddQ(pcOtherStr)
			This.Add(pcOtherStr)
			return This

	def AddToEnd(pcOtherStr)
		This.Append(pcOtherStr)

		def AddToEndQ(pcOtherStr)
			This.AddToEnd(pcOtherStr)
			return This

	def AddEnd(pcOtherStr)
		This.Append(pcOtherStr)

		def AddEndQ(pcOtherStr)
			This.AddEnd(pcOtherStr)
			return This

	#--

	def AppendEnd(pcOtherStr)
		This.Append(pcOtherStr)

		def AppendEndQ(pcOtherStr)
			This.AppendEnd(pcOtherStr)
			return This

	def AppendFromEnd(pcOtherStr)
		This.Append(pcOtherStr)

		def AppendFromEndQ(pcOtherStr)
			This.AppendFromEnd(pcOtherStr)
			return This

	def AppendAtEnd(pcOtherStr)
		This.Append(pcOtherStr)

		def AppendAtEndQ(pcOtherStr)
			This.AppendAtEnd(pcOtherStr)
			return This

	#--

	def Extend(pcOtherStr)
		This.Append(pcOtherStr)

		def ExtendQ(pcOtherStr)
			This.Extend(pcOtherStr)
			return This

	def ExtendEnd(pcOtherStr)
		This.Append(pcOtherStr)

		def ExtendEndQ(pcOtherStr)
			This.ExtendEnd(pcOtherStr)
			return This

	def ExtendFromEnd(pcOtherStr)
		This.Append(pcOtherStr)

		def ExtendFromEndQ(pcOtherStr)
			This.ExtendFromEnd(pcOtherStr)
			return This

	def ExtendAtEnd(pcOtherStr)
		This.Append(pcOtherStr)

		def ExtendAtEndQ(pcOtherStr)
			This.ExtendFAtEnd(pcOtherStr)
			return This

	  #-------------------------------#
	 #   ALTERNATIVES OF Appended()  #
	#-------------------------------#

	def Added(pcOtherStr)
		return This.Appended(pcOtherStr)

	def AddedToEnd(pcOtherStr)
		return This.Appended(pcOtherStr)

	def AppendedFromEnd(pcOtherStr)
		return This.Appended(pcOtherStr)

	def AppendedAtEnd(pcOtherStr)
		return This.Appended(pcOtherStr)

	#--

	def Extended(pcOtherStr)
		return This.Appended(pcOtherStr)

	def ExtendedFromEnd(pcOtherStr)
		return This.Appended(pcOtherStr)

	def ExtendedAtEnd(pcOtherStr)
		return This.Appended(pcOtherStr)

	  #----------------------------#
	 #  ALTERNATIVES OF Prepend()  #
	#----------------------------#

	def AddStart(pcOtherStr)
		This.Prepend(pcOtherStr)

		def AddStartQ(pcOtherStr)
			This.AddStart(pcOtherStr)
			return This

	def AddToStart(pcOtherStr)
		This.Prepend(pcOtherStr)

		def AddToStartQ(pcOtherStr)
			This.AddToStart(pcOtherStr)
			return This

	def AddAtStart(pcOtherStr)
		This.Prepend(pcOtherStr)

		def AddAtStartQ(pcOtherStr)
			This.AddAtStart(pcOtherStr)
			return This

	def AddFromStart(pcOtherStr)
		This.Prepend(pcOtherStr)

		def AddFromStartQ(pcOtherStr)
			This.AddFromStart(pcOtherStr)
			return This

	#--

	def ExtendStart(pcOtherStr)
		This.Prepend(pcOtherStr)

		def ExtendStartQ(pcOtherStr)
			This.ExtendStart(pcOtherStr)
			return This

	def ExtendToStart(pcOtherStr)
		This.Prepend(pcOtherStr)

		def ExtendToStartQ(pcOtherStr)
			This.ExtendToStart(pcOtherStr)
			return This

	def ExtendAtStart(pcOtherStr)
		This.Prepend(pcOtherStr)

		def ExtendAtStartQ(pcOtherStr)
			This.ExtendAtStart(pcOtherStr)
			return This

	def ExtendFromStart(pcOtherStr)
		This.Prepend(pcOtherStr)

		def ExtendFromStartQ(pcOtherStr)
			This.ExtendFromStart(pcOtherStr)
			return This

	  #--------------------------------#
	 #   ALTERNATIVES OF Prepended()  #
	#--------------------------------#

	def AddedToStart(pcOtherStr)
		return This.Prepended(pcOtherStr)

	def AppendedFromStart(pcOtherStr)
		return This.Prepended(pcOtherStr)

	def AppendedAtStart(pcOtherStr)
		return This.Prepended(pcOtherStr)

	#--

	def ExtendedToStart(pcOtherStr)
		return This.Prepended(pcOtherStr)

	def ExtendedFromStart(pcOtherStr)
		return This.Prepended(pcOtherStr)

	def ExtendedAtStart(pcOtherStr)
		return This.Prepended(pcOtherStr)

	  #--------------------------#
	 #  ALTERNATIVES OF Find()  #
	#--------------------------#

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

	  #-------------------------------#
	 #  ALTERNATIVES OF FindManyZ()  #
	#-------------------------------#

	def TheseSubStringsAndTheirPositionsCS(pacSubStr, pCaseSensitive)
		return This.FindManyZCS(pacSubStr, pCaseSensitive)

		def TheseSubStringsAndTheirPositionsCSQ(pacSubStr, pCaseSensitive)
			return This.FindManyZCSQ(pacSubStr, pCaseSensitive)

		def TheseSubStringsAndTheirPositionsCSQR(pacSubStr, pcReturnType)
			return This.FindManyZCSQR(pacSubStr, pCaseSensitive, pcReturnType)

	#-- WITHOUT CASESENSITIVITY

	def TheseSubStringsAndTheirPositions(pacSubStr)
		return This.FindManyZ(pacSubStr)

		def TheseSubStringsAndTheirPositionsQ(pacSubStr)
			return This.FindManyZZQ(pacSubStr)

		def TheseSubStringsAndTheirPositionsQR(pacSubStr, pcReturnType)
			return This.FindManyZQR(pacSubStr, pcReturnType)

	  #--------------------------------#
	 #  ALTERNATIVES OF FindManyZZ()  #
	#--------------------------------#

	def TheseSubStringsAndTheirSectionsCS(pacSubStr, pCaseSensitive)
		return This.FindManyZZCS(pacSubStr, pCaseSensitive)

		def TheseSubStringsAndTheirSectionsCSQ(pacSubStr, pCaseSensitive)
			return This.FindManyZZCSQ(pacSubStr, pCaseSensitive)

		def TheseSubStringsAndTheirSectionsCSQR(pacSubStr, pcReturnType)
			return This.FindManyZZCSQR(pacSubStr, pCaseSensitive, pcReturnType)

	#-- WITHOUT CASESENSITIVITY

	def TheseSubStringsAndTheirSections(pacSubStr)
		return This.FindManyZZ(pacSubStr)

		def TheseSubStringsAndTheirSectionsQ(pacSubStr)
			return This.FindManyZZQ(pacSubStr)

		def TheseSubStringsAndTheirSectionsQR(pacSubStr, pcReturnType)
			return This.FindManyZZQR(pacSubStr, pcReturnType)

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

	  #----------------------------------------------#
	 #  ALTERNATIVES OF FindSplittedByAsSections()  #
	#----------------------------------------------#

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

	  #---------------------------------#
	 #  ALTERNATIVES OF DeepBetween()  #
	#---------------------------------#

	def AnyDeepBetweenCSQ(pcChar1, pcChar2, pCaseSensitive)
		return This.DeepBetweenCS(pcChar1, pcChar2, pCaseSensitive)

	#--

	def DeepSubStringsBetweenCS(pcChar1, pcChar2, pCaseSensitive)
		return This.DeepBetweenCS(pcChar1, pcChar2, pCaseSensitive)

	def AnyDeepSubStringBetweenCS(pcChar1, pcChar2, pCaseSensitive)
		return This.DeepSubStringsBetweenCS(pcChar1, pcChar2, pCaseSensitive)

		def AnyDeepSubStringBetweenCSQ(pcChar1, pcChar2, pCaseSensitive)
			return This.DeepSubStringsBetweenCSQ(pcChar1, pcChar2, pCaseSensitive)

		def AnyDeepSubStringBetweenCSQR(pcChar1, pcChar2, pCaseSensitive, pcReturnType)
			return This.DeepSubStringsBetweenQR(pcChar1, pcChar2, pCaseSensitive, pcReturnType)

	def AnyDeepSubStringsBetweenCS(pcChar1, pcChar2, pCaseSensitive)
		return This.DeepSubStringsBetweenCS(pcChar1, pcChar2, pCaseSensitive)

		def AnyDeepSubStringsBetweenCSQ(pcChar1, pcChar2, pCaseSensitive)
			return This.DeepSubStringsBetweenCSQ(pcChar1, pcChar2, pCaseSensitive)

		def AnyDeepSubStringsBetweenCSQR(pcChar1, pcChar2, pCaseSensitive, pcReturnType)
			return This.DeepSubStringsBetweenQR(pcChar1, pcChar2, pCaseSensitive, pcReturnType)

	#-- Allowing the use of "SECTION" along with "SUBSTRING"

	def DeepSectionsBetweenCS(pcChar1, pcChar2, pCaseSensitive)
		return This.DeepSubstringsBetweenCS(pcChar1, pcChar2, pCaseSensitive)

		def DeepSectionsBetweenCSQ(pcChar1, pcChar2, pCaseSensitive)
			return This.DeepSubStringsBetweenCSQ(pcChar1, pcChar2, pCaseSensitive)

	def AnyDeepSectionBetweenCS(pcChar1, pcChar2, pCaseSensitive)
		return This.DeepSectionsBetweenCS(pcChar1, pcChar2, pCaseSensitive)

		def AnyDeepSectionBetweenCSQ(pcChar1, pcChar2, pCaseSensitive)
			return This.DeepSectionsBetweenCSQ(pcChar1, pcChar2, pCaseSensitive)

		def AnyDeepSectionBetweenCSQR(pcChar1, pcChar2, pCaseSensitive, pcReturnType)
			return This.DeepSectionsBetweenQR(pcChar1, pcChar2, pCaseSensitive, pcReturnType)

	def AnyDeepSectionsBetweenCS(pcChar1, pcChar2, pCaseSensitive)
		return This.DeepSectionsBetweenCS(pcChar1, pcChar2, pCaseSensitive)

		def AnyDeepSectionsBetweenCSQ(pcChar1, pcChar2, pCaseSensitive)
			return This.DeepSectionsBetweenCSQ(pcChar1, pcChar2, pCaseSensitive)

		def AnyDeepDeepSectionsBetweenCSQR(pcChar1, pcChar2, pCaseSensitive, pcReturnType)
			return This.DeepDeepSectionsBetweenQR(pcChar1, pcChar2, pCaseSensitive, pcReturnType)

	#-- WITHOUT CASESENSITIVITY

	def AnyDeepBetweenQ(pcChar1, pcChar2)
		return This.DeepSubStringsBetween(pcChar1, pcChar2)

	#--

	def AnyDeepSubStringBetween(pcChar1, pcChar2)
		return This.DeepSubStringsBetween(pcChar1, pcChar2)

		def AnyDeepSubStringBetweenQ(pcChar1, pcChar2)
			return This.DeepSubStringsBetweenQ(pcChar1, pcChar2)

		def AnyDeepSubStringBetweenQR(pcChar1, pcChar2, pcReturnType)
			return This.DeepSubStringsBetweenQR(pcChar1, pcChar2, pcReturnType)

	def AnyDeepSubStringsBetween(pcChar1, pcChar2)
		return This.DeepSubStringsBetween(pcChar1, pcChar2)

		def AnyDeepSubStringsBetweenQ(pcChar1, pcChar2)
			return This.DeepSubStringsBetweenQ(pcChar1, pcChar2)

		def AnyDeepSubStringsBetweenQR(pcChar1, pcChar2, pcReturnType)
			return This.DeepSubStringsBetweenQR(pcChar1, pcChar2, pcReturnType)

	#-- Allowing the use of "SECTION" along with "SUBSTRING"

	def DeepSectionsBetween(pcChar1, pcChar2)
		return This.DeepSubstringsBetween(pcChar1, pcChar2)

		def DeepSectionsBetweenQ(pcChar1, pcChar2)
			return This.DeepSubStringsBetweenQ(pcChar1, pcChar2)

	def AnyDeepSectionBetween(pcChar1, pcChar2)
		return This.DeepSectionsBetween(pcChar1, pcChar2)

		def AnyDeepSectionBetweenQ(pcChar1, pcChar2)
			return This.DeepSectionsBetweenQ(pcChar1, pcChar2)

		def AnyDeepSectionBetweenQR(pcChar1, pcChar2, pcReturnType)
			return This.DeepSectionsBetweenQR(pcChar1, pcChar2, pcReturnType)

	def AnyDeepSectionsBetween(pcChar1, pcChar2)
		return This.DeepSectionsBetween(pcChar1, pcChar2)

		def AnyDeepSectionsBetweenQ(pcChar1, pcChar2)
			return This.DeepSectionsBetweenQ(pcChar1, pcChar2)

		def AnyDeepSectionsBetweenQR(pcChar1, pcChar2, pcReturnType)
			return This.DeepSectionsBetweenQR(pcChar1, pcChar2, pcReturnType)

	  #-------------------------------------------#
	 #  ALTERNATIVES OF DeepSubStringsBetween()  #
	#-------------------------------------------#

	def AnyDeepBetweenIBCS(pcChar1, pcChar2, pCaseSensitive)
		return This.DeepSubStringsBetweenIBCS(pcChar1, pcChar2, pCaseSensitive)

		def AnyDeepBetweenIBCSQ(pcChar1, pcChar2, pCaseSensitive)
			return This.DeepSubStringsBetweenIBQCS(pcChar1, pcChar2, pCaseSensitive)

		def AnyDeepBetweenIBCSQR(pcChar1, pcChar2, pCaseSensitive, pcReturnType)
			return This.DeepSubStringsBetweenIBQRCS(pcChar1, pcChar2, pCaseSensitive, pcReturnType)

	def AnyDeepSubStringBetweenIBCS(pcChar1, pcChar2, pCaseSensitive)
		return This.DeepSubStringsBetweenIBCS(pcChar1, pcChar2, pCaseSensitive)

		def AnyDeepSubStringBetweenIBCSQ(pcChar1, pcChar2, pCaseSensitive)
			return This.DeepSubStringsBetweenCSQ(pcChar1, pcChar2, pCaseSensitive)

		def AnyDeepSubStringBetweenIBCSQR(pcChar1, pcChar2, pCaseSensitive, pcReturnType)
			return This.DeepSubStringsBetweenIBQR(pcChar1, pcChar2, pCaseSensitive, pcReturnType)

	def AnyDeepSubStringsBetweenIBCS(pcChar1, pcChar2, pCaseSensitive)
		return This.DeepSubStringsBetweenIBCS(pcChar1, pcChar2, pCaseSensitive)

		def AnyDeepSubStringsBetweenIBCSQ(pcChar1, pcChar2, pCaseSensitive)
			return This.DeepSubStringsBetweenCSQ(pcChar1, pcChar2, pCaseSensitive)

		def AnyDeepSubStringsBetweenIBCSQR(pcChar1, pcChar2, pCaseSensitive, pcReturnType)
			return This.DeepSubStringsBetweenIBQR(pcChar1, pcChar2, pCaseSensitive, pcReturnType)

	#-- Allowing the use of "SECTION" along with "SUBSTRING"

	def DeepSectionsBetweenIBCS(pcChar1, pcChar2, pCaseSensitive)
		return This.DeepSubstringsBetweenIBCS(pcChar1, pcChar2, pCaseSensitive)

		def DeepSectionsBetweenIBCSQ(pcChar1, pcChar2, pCaseSensitive)
			return This.DeepSubStringsBetweenCSQ(pcChar1, pcChar2, pCaseSensitive)

	def AnyDeepSectionBetweenIBCS(pcChar1, pcChar2, pCaseSensitive)
		return This.DeepSectionsBetweenIBCS(pcChar1, pcChar2, pCaseSensitive)

		def AnyDeepSectionBetweenIBCSQ(pcChar1, pcChar2, pCaseSensitive)
			return This.DeepSectionsBetweenCSQ(pcChar1, pcChar2, pCaseSensitive)

		def AnyDeepSectionBetweenIBCSQR(pcChar1, pcChar2, pCaseSensitive, pcReturnType)
			return This.DeepSectionsBetweenIBQR(pcChar1, pcChar2, pCaseSensitive, pcReturnType)

	def AnyDeepSectionsBetweenIBCS(pcChar1, pcChar2, pCaseSensitive)
		return This.DeepSectionsBetweenIBCS(pcChar1, pcChar2, pCaseSensitive)

		def AnyDeepSectionsBetweenIBCSQ(pcChar1, pcChar2, pCaseSensitive)
			return This.DeepSectionsBetweenCSQ(pcChar1, pcChar2, pCaseSensitive)

		def AnyDeepDeepSectionsBetweenIBCSQR(pcChar1, pcChar2, pCaseSensitive, pcReturnType)
			return This.DeepDeepSectionsBetweenIBQR(pcChar1, pcChar2, pCaseSensitive, pcReturnType)

	#-- WITHOUT CASESENSITIVITY

	def AnyDeepBetweenIB(pcChar1, pcChar2)
		return This.DeepSubStringsBetweenIB(pcChar1, pcChar2)

		def AnyDeepBetweenIBQ(pcChar1, pcChar2)
			return This.DeepSubStringsBetweenIBQ(pcChar1, pcChar2)

		def AnyDeepBetweenIBQR(pcChar1, pcChar2, pcReturnType)
			return This.DeepSubStringsBetweenIBQR(pcChar1, pcChar2, pcReturnType)

	def AnyDeepSubStringBetweenIB(pcChar1, pcChar2)
		return This.DeepSubStringsBetweenIB(pcChar1, pcChar2)

		def AnyDeepSubStringBetweenIBQ(pcChar1, pcChar2)
			return This.DeepSubStringsBetweenIBQ(pcChar1, pcChar2)

		def AnyDeepSubStringBetweenIBQR(pcChar1, pcChar2, pcReturnType)
			return This.DeepSubStringsBetweenIBQR(pcChar1, pcChar2, pcReturnType)

	def AnyDeepSubStringsBetweenIB(pcChar1, pcChar2)
		return This.DeepSubStringsBetweenIB(pcChar1, pcChar2)

		def AnyDeepSubStringsBetweenIBQ(pcChar1, pcChar2)
			return This.DeepSubStringsBetweenIBQ(pcChar1, pcChar2)

		def AnyDeepSubStringsBetweenIBQR(pcChar1, pcChar2, pcReturnType)
			return This.DeepSubStringsBetweenIBQR(pcChar1, pcChar2, pcReturnType)

	#-- Allowing the use of "SECTION" along with "SUBSTRING"

	def DeepSectionsBetweenIB(pcChar1, pcChar2)
		return This.DeepSubstringsBetweenIB(pcChar1, pcChar2)

		def DeepSectionsBetweenIBQ(pcChar1, pcChar2)
			return This.DeepSubStringsBetweenIBQ(pcChar1, pcChar2)

	def AnyDeepSectionBetweenIB(pcChar1, pcChar2)
		return This.DeepSectionsBetweenIB(pcChar1, pcChar2)

		def AnyDeepSectionBetweenIBQ(pcChar1, pcChar2)
			return This.DeepSectionsBetweenIBQ(pcChar1, pcChar2)

		def AnyDeepSectionBetweenIBQR(pcChar1, pcChar2, pcReturnType)
			return This.DeepSectionsBetweenIBQR(pcChar1, pcChar2, pcReturnType)

	def AnyDeepSectionsBetweenIB(pcChar1, pcChar2)
		return This.DeepSectionsBetweenIB(pcChar1, pcChar2)

		def AnyDeepSectionsBetweenIBQ(pcChar1, pcChar2)
			return This.DeepSectionsBetweenIBQ(pcChar1, pcChar2)

		def AnyDeepSectionsBetweenIBQR(pcChar1, pcChar2, pcReturnType)
			return This.DeepSectionsBetweenIBQR(pcChar1, pcChar2, pcReturnType)

	  #---------------------------------------#
	 #  ALTERNATIVES OF RemoveSubStringAt()  #
	#---------------------------------------#

	def RemoveAtCS(n, pcSubStr, pCaseSensitive)
		This.RemoveSubStringAtCS(n, pcSubStr, pCaseSensitive)

		def RemoveAtCSQ(n, pcSubStr, pCaseSensitive)
			This.RemoveAtCS(n, pcSubStr, pCaseSensitive)
			return This

	def RemoveAtPositionCS(n, pcSubStr, pCaseSensitive)
		This.RemoveSubStringAtCS(n, pcSubStr, pCaseSensitive)

		def RemoveAtPositionCSQ(n, pcSubStr, pCaseSensitive)
			This.RemoveAtPositionCS(n, pcSubStr, pCaseSensitive)
			return This

	#-- WITHOUT CASESENSITIVITY

	def RemoveAt(n, pcSubStr)
		This.RemoveSubStringAtPosition(n, pcSubStr)

		def RemoveAtQ(n, pcSubStr)
			This.RemoveAt(n, pcSubStr)
			return This

	def RemoveAtPosition(n, pcSubStr)
		This.RemoveSubStringAtPosition(n, pcSubStr)

		def RemoveAtPositionQ(n, pcSubStr)
			This.RemoveAtPosition(n, pcSubStr)
			return This

	  #----------------------------------#
	 #  ALTERNATIVES OF ContainsSome()  #
	#----------------------------------#

	def ContainsOneOrMoreOccurrencesCS(paSubStr, pCaseSensitive)
		return This.ContainsSomeCS(paSubStr, pCaseSensitive)

	def ContainsOneOrMoreOfTheseCS(paSubStr, pCaseSensitive)
		return This.ContainsSomeCS(paSubStr, pCaseSensitive)

	def ContainsSomeOfTheseCS(paSubStr, pCaseSensitive)
		return This.ContainsSomeCS(paSubStr, pCaseSensitive)

	#--

	 def ContainsOneOrMoreOfTheseSubStringsCS(paSubStr, pCaseSensitive)
		return This.ContainsSomeCS(paSubStr, pCaseSensitive)

	def ContainsSomeOfTheseSubStringsCS(paSubStr, pCaseSensitive)
		return This.ContainsSomeCS(paSubStr, pCaseSensitive)

	#--

	def ContainsOneOrMoreSubStringOfCS(paSubStr, pCaseSensitive)
		return This.ContainsSomeCS(paSubStr, pCaseSensitive)

	def ContainsOneOrMoreSubStringOfTheseCS(paSubStr, pCaseSensitive)
		return This.ContainsSomeCS(paSubStr, pCaseSensitive)

	#--

	def ContainsManyOccurrencesCS(pcSubstr, pCaseSensitive)
		return This.ContainsSomeCS(pcSubstr, pCaseSensitive)
		
	def ContainsManyCS(pcSubStr, pCaseSensitive)
		return This.ContainsSomeCS(pcSubstr, pCaseSensitive)
		
	def ContainsSomeOccurrencesCS(pcSubstr, pCaseSensitive)
		return This.ContainsSomeCS(pcSubstr, pCaseSensitive)
				
	def ContainsMoreThenOneCS(pcSubStr, pCaseSensitive)
		return This.ContainsSomeCS(pcSubstr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsOneOrMoreOccurrences(paSubStr)
		return This.ContainsSome(paSubStr)

	def ContainsOneOrMoreOfThese(paSubStr)
		return This.ContainsSome(paSubStr)

	def ContainsSomeOfThese(paSubStr)
		return This.ContainsSome(paSubStr)

	#--

	 def ContainsOneOrMoreOfTheseSubStrings(paSubStr)
		return This.ContainsSome(paSubStr)

	def ContainsSomeOfTheseSubStrings(paSubStr)
		return This.ContainsSome(paSubStr)

	#--

	def ContainsOneOrMoreSubStringOf(paSubStr)
		return This.ContainsSome(paSubStr)

	def ContainsOneOrMporeSubStringOfThese(paSubStr)
		return This.ContainsSome(paSubStr)

	#--

	def ContainsManyOccurrences(pcSubstr)
		return This.ContainsSome(pcSubstr)
		
	def ContainsMany(pcSubStr)
		return This.ContainsSome(pcSubstr)
		
	def ContainsSomeOccurrences(pcSubstr)
		return This.ContainsSome(pcSubstr)
				
	def ContainsMoreThenOne(pcSubStr)
		return This.ContainsSome(pcSubstr)
	
	  #--------------------------------------#
	 #  ALTERNATIVES OF RemoveAnyBetween()  #
	#--------------------------------------#

	def RemoveSubStringsBetweenCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveAnyBetweenCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveSubStringsBetweenCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveSubStringsBetweenCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveAnySubStringBetweenCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveAnyBetweenCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveAnySubStringBetweenCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnySubStringBetweenCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveAnySubStringsBetweenCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveAnyBetweenCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveAnySubStringsBetweenCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnySubStringsBetweenCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	#--

	def RemoveAnyBoundedByCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveBoundedByCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveAnyBoundedByCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnyBoundedByCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveSubStringsBoundedByCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveBoundedByCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveSubStringsBoundedByCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveSubStringsBoundedByCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveAnySubStringBoundedByCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveBoundedByCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveAnySubStringBoundedByCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnySubStringBoundedByCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveAnySubStringsBoundedByCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveBoundedByCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveAnySubStringsBoundedByCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnySubStringsBoundedByCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	#-- Allowing the use of "SECTION" instead of "SUBSTRING"

	def RemoveSectionsBetweenCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveAnyBetweenCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveSectionsBetweenCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveSectionsBetweenCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveAnySectionBetweenCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveAnyBetweenCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveAnySectionBetweenCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnySectionBetweenCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveAnySectionsBetweenCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveAnyBetweenCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveAnySectionsBetweenCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnySectionsBetweenCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	#--

	def RemoveSectionsBoundedByCS(paBounds, pCaseSensitive)
		This.RemoveBetweenByCS(paBounds[1], paBounds[2], pCaseSensitive)

		def RemoveSectionsBoundedByCSQ(paBounds, pCaseSensitive)
			This.RemoveSectionsBoundedByCS(paBounds, pCaseSensitive)
			return This

	def RemoveAnySectionBoundedByCS(paBounds, pCaseSensitive)
		This.RemoveAnyBetweenCS(paBounds[1], paBounds[2], pCaseSensitive)

		def RemoveAnySectionBoundedByCSQ(paBounds, pCaseSensitive)
			This.RemoveAnySectionBoundedByCS(paBounds, pCaseSensitive)
			return This

	def RemoveAnySectionsBoundedByCS(paBounds, pCaseSensitive)
		This.RemoveBetweenByCS(paBounds[1], paBounds[2], pCaseSensitive)

		def RemoveAnySectionsBoundedByCSQ(paBounds, pCaseSensitive)
			This.RemoveAnySectionsBoundedByCS(paBounds, pCaseSensitive)
			return This
	
	#-- WTHOUT CASESENSITIVITY

	def RemoveSubStringsBetween(pcBound1, pcBound2)
		This.RemoveAnyBetween(pcBound1, pcBound2)

		def RemoveSubStringsBetweenQ(pcBound1, pcBound2)
			This.RemoveSubStringsBetween(pcBound1, pcBound2)
			return This

	def RemoveAnySubStringBetween(pcBound1, pcBound2)
		This.RemoveAnyBetween(pcBound1, pcBound2)

		def RemoveAnySubStringBetweenQ(pcBound1, pcBound2)
			This.RemoveAnySubStringBetween(pcBound1, pcBound2)
			return This

	def RemoveAnySubStringsBetween(pcBound1, pcBound2)
		This.RemoveAnyBetween(pcBound1, pcBound2)

		def RemoveAnySubStringsBetweenQ(pcBound1, pcBound2)
			This.RemoveAnySubStringsBetween(pcBound1, pcBound2)
			return This

	#--

	def RemoveAnyBoundedBy(pcBound1, pcBound2)
		This.RemoveBoundedBy(pcBound1, pcBound2)

		def RemoveAnyBoundedByQ(pcBound1, pcBound2)
			This.RemoveAnyBoundedBy(pcBound1, pcBound2)
			return This

	def RemoveSubStringsBoundedBy(pcBound1, pcBound2)
		This.RemoveBoundedBy(pcBound1, pcBound2)

		def RemoveSubStringsBoundedByQ(pcBound1, pcBound2)
			This.RemoveSubStringsBoundedBy(pcBound1, pcBound2)
			return This

	def RemoveAnySubStringBoundedBy(pcBound1, pcBound2)
		This.RemoveBoundedBy(pcBound1, pcBound2)

		def RemoveAnySubStringBoundedByQ(pcBound1, pcBound2)
			This.RemoveAnySubStringBoundedBy(pcBound1, pcBound2)
			return This

	def RemoveAnySubStringsBoundedBy(pcBound1, pcBound2)
		This.RemoveBoundedBy(pcBound1, pcBound2)

		def RemoveAnySubStringsBoundedByQ(pcBound1, pcBound2)
			This.RemoveAnySubStringsBoundedBy(pcBound1, pcBound2)
			return This

	#-- Allowing the use of "SECTION" instead of "SUBSTRING"

	def RemoveSectionsBetween(pcBound1, pcBound2)
		This.RemoveAnyBetween(pcBound1, pcBound2)

		def RemoveSectionsBetweenQ(pcBound1, pcBound2)
			This.RemoveSectionsBetween(pcBound1, pcBound2)
			return This

	def RemoveAnySectionBetween(pcBound1, pcBound2)
		This.RemoveAnyBetween(pcBound1, pcBound2)

		def RemoveAnySectionBetweenQ(pcBound1, pcBound2)
			This.RemoveAnySectionBetween(pcBound1, pcBound2)
			return This

	def RemoveAnySectionsBetween(pcBound1, pcBound2)
		This.RemoveAnyBetween(pcBound1, pcBound2)

		def RemoveAnySectionsBetweenQ(pcBound1, pcBound2)
			This.RemoveAnySectionsBetween(pcBound1, pcBound2)
			return This

	#--

	def RemoveSectionsBoundedBy(paBounds)
		This.RemoveBetweenBy(paBounds[1], paBounds[2])

		def RemoveSectionsBoundedByQ(paBounds)
			This.RemoveSectionsBoundedBy(paBounds)
			return This

	def RemoveAnySectionBoundedBy(paBounds)
		This.RemoveAnyBetween(paBounds[1], paBounds[2])

		def RemoveAnySectionBoundedByQ(paBounds)
			This.RemoveAnySectionBoundedBy(paBounds)
			return This

	def RemoveAnySectionsBoundedBy(paBounds)
		This.RemoveBetweenBy(paBounds[1], paBounds[2])

		def RemoveAnySectionsBoundedByQ(paBounds)
			This.RemoveAnySectionsBoundedBy(paBounds)
			return This

	  #---------------------------------------#
	 #  ALTERNATIVES OF AnyBetweenRemoved()  #
	#---------------------------------------#

	def SubStringsBetweenRemovedCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedCS(pcBound1, pcBound2, pCaseSensitive)

	def AnySubStringBetweenRemovedCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedCS(pcBound1, pcBound2, pCaseSensitive)

	def AnySubStringsBetweenRemovedCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedCS(pcBound1, pcBound2, pCaseSensitive)

	#--

	def AnyBoundedByRemovedCS(paBounds, pCaseSensitive)
		return This.AnyBetweenRemovedCS(paBounds[1], paBounds[2], pCaseSensitive)

	def SubStringsBoundedByRemovedCS(paBounds, pCaseSensitive)
		return This.AnyBetweenRemovedCS(paBounds[1], paBounds[2], pCaseSensitive)

	def AnySubStringBoundedByRemovedCS(paBounds, pCaseSensitive)
		return This.AnyBetweenRemovedCS(paBounds[1], paBounds[2], pCaseSensitive)

	def AnySubStringsBoundedByRemovedCS(paBounds, pCaseSensitive)
		return This.AnyBetweenRemovedCS(paBounds[1], paBounds[2], pCaseSensitive)

	#-- Allowing the use of "SECTION" instead of "SUBSTRING"

	def AnySectionBetweenRemovedCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedCS(pcBound1, pcBound2, pCaseSensitive)

	def AnySectionsBetweenRemovedCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedCS(pcBound1, pcBound2, pCaseSensitive)

	#--

	def SectionsBoundedByRemovedCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedCS(pcBound1, pcBound2, pCaseSensitive)

	def AnySectionBoundedByRemovedCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedCS(pcBound1, pcBound2, pCaseSensitive)

	def AnySectionsBoundedByRemovedCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedCS(pcBound1, pcBound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SubStringsBetweenRemoved(pcBound1, pcBound2)
		return This.AnyBetweenRemoved(pcBound1, pcBound2)

	def AnySubStringBetweenRemoved(pcBound1, pcBound2)
		return This.AnyBetweenRemoved(pcBound1, pcBound2)

	def AnySubStringsBetweenRemoved(pcBound1, pcBound2)
		return This.AnyBetweenRemoved(pcBound1, pcBound2)

	#--

	def AnyBoundedByRemoved(paBounds)
		return This.AnyBetweenRemoved(paBounds[1], paBounds[2])

	def SubStringsBoundedByRemoved(paBounds)
		return This.AnyBetweenRemoved(paBounds[1], paBounds[2])

	def AnySubStringBoundedByRemoved(paBounds)
		return This.AnyBetweenRemoved(paBounds[1], paBounds[2])

	def AnySubStringsBoundedByRemoved(paBounds)
		return This.AnyBetweenRemoved(paBounds[1], paBounds[2])

	#-- Allowing the use of "SECTION" instead of "SUBSTRING"

	def AnySectionBetweenRemoved(pcBound1, pcBound2)
		return This.AnyBetweenRemoved(pcBound1, pcBound2)

	def AnySectionsBetweenRemoved(pcBound1, pcBound2)
		return This.AnyBetweenRemoved(pcBound1, pcBound2)

	#--

	def SectionsBoundedByRemoved(pcBound1, pcBound2)
		return This.AnyBetweenRemoved(pcBound1, pcBound2)

	def AnySectionBoundedByRemoved(pcBound1, pcBound2)
		return This.AnyBetweenRemoved(pcBound1, pcBound2)

	def AnySectionsBoundedByRemoved(pcBound1, pcBound2)
		return This.AnyBetweenRemoved(pcBound1, pcBound2)

	  #-----------------------------------#
	 #  ALTERNATIVES OF RemoveBetween()  #
	#-----------------------------------#

	def RemoveThisBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		This.RemoveBetweenCS(pcSubStr,pcBound1, pcBound2, pCaseSensitive)

		def RemoveThisBetweenCSQ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			This.RemoveThisBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveThisSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
		This.RemoveBetweenCS(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

		def RemoveThisSubStringBoundedByCSQ(pcSubStr, pacBounds, pCaseSensitive)
			This.RemoveThisSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This

	#--

	def RemoveSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		This.RemoveBetweenCS(pcSubStr,pcBound1, pcBound2, pCaseSensitive)

		def RemoveSubStringBetweenCSQ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			This.RemoveSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
		This.RemoveBetweenCS(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

		def RemoveSubStringBoundedByCSQ(pcSubStr, pacBounds, pCaseSensitive)
			This.RemoveSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This

	#--

	def RemoveThisSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		This.RemoveBetweenCS(pcSubStr,pcBound1, pcBound2, pCaseSensitive)

		def RemoveThisSubStringBetweenCSQ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			This.RemoveSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This

	#-- WITHOUT CASESENSITIVITY

	def RemoveThisBetween(pcSubStr, pcBound1, pcBound2)
		This.RemoveBetween(pcSubStr,pcBound1, pcBound2)

		def RemoveThisBetweenQ(pcSubStr, pcBound1, pcBound2)
			This.RemoveThisBetween(pcSubStr, pcBound1, pcBound2)
			return This

	def RemoveThisSubStringBoundedBy(pcSubStr, pacBounds)
		This.RemoveBetween(pcSubStr, pacBounds[1], pacBounds[2])

		def RemoveThisSubStringBoundedByQ(pcSubStr, pacBounds)
			This.RemoveThisSubStringBoundedBy(pcSubStr, pacBounds)
			return This

	#--

	def RemoveSubStringBetween(pcSubStr, pcBound1, pcBound2)
		This.RemoveBetween(pcSubStr,pcBound1, pcBound2)

		def RemoveSubStringBetweenQ(pcSubStr, pcBound1, pcBound2)
			This.RemoveSubStringBetween(pcSubStr, pcBound1, pcBound2)
			return This

	def RemoveSubStringBoundedBy(pcSubStr, pacBounds)
		This.RemoveBetween(pcSubStr, pacBounds[1], pacBounds[2])

		def RemoveSubStringBoundedByQ(pcSubStr, pacBounds)
			This.RemoveSubStringBoundedBy(pcSubStr, pacBounds)
			return This

	#--

	def RemoveThisSubStringBetween(pcSubStr, pcBound1, pcBound2)
		This.RemoveBetween(pcSubStr,pcBound1, pcBound2)

		def RemoveThisSubStringBetweenQ(pcSubStr, pcBound1, pcBound2)
			This.RemoveSubStringBetween(pcSubStr, pcBound1, pcBound2)
			return This

	  #--------------------------------------#
	 #  ALTERNATIVES OF RemoveAnyBetween()  #
	#--------------------------------------#

	def RemoveSubStringsBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveAnyBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveSubStringsBetweenIBCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveSubStringsBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveAnySubStringBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveAnyBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveAnySubStringBetweenIBCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnySubStringBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveAnySubStringsBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveAnyBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveAnySubStringsBetweenIBCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnySubStringsBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	#--

	def RemoveSubStringsBoundedByIBCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveAnyBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveSubStringsBoundedByIBCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveSubStringsBoundedByIBCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveAnySubStringBoundedByIBCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveAnyBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveAnySubStringBoundedByIBCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnySubStringBoundedByIBCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveAnySubStringsBoundedByIBCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveAnyBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveAnySubStringsBoundedByIBCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnySubStringsBoundedByIBCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	#-- Allowing the use of "SECTION" instead of "SUBSTRING"

	def RemoveSectionsBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveAnyBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveSectionsBetweenIBCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveSectionsBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveAnySectionBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveAnyBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveAnySectionBetweenIBCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnySectionBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveAnySectionsBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveAnyBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveAnySectionsBetweenIBCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnySectionsBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	#--

	def RemoveSectionsBoundedByIBCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveAnyBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveSectionsBoundedByIBCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveSectionsBoundedByIBCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveAnySectionBoundedByIBCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveAnyBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveAnySectionBoundedByIBCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnySectionBoundedByIBCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	def RemoveAnySectionsBoundedByIBCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveAnyBetweenIBCS(pcBound1, pcBound2, pCaseSensitive)

		def RemoveAnySectionsBoundedByIBCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnySectionsBoundedByIBCS(pcBound1, pcBound2, pCaseSensitive)
			return This

	#-- WITHOUT CASESENSITIVITY

	def RemoveSubStringsBetweenIB(pcBound1, pcBound2)
		This.RemoveAnyBetweenIB(pcBound1, pcBound2)

		def RemoveSubStringsBetweenIBQ(pcBound1, pcBound2)
			This.RemoveSubStringsBetweenIB(pcBound1, pcBound2)
			return This

	def RemoveAnySubStringBetweenIB(pcBound1, pcBound2)
		This.RemoveAnyBetweenIB(pcBound1, pcBound2)

		def RemoveAnySubStringBetweenIBQ(pcBound1, pcBound2)
			This.RemoveAnySubStringBetweenIB(pcBound1, pcBound2)
			return This

	def RemoveAnySubStringsBetweenIB(pcBound1, pcBound2)
		This.RemoveAnyBetweenIB(pcBound1, pcBound2)

		def RemoveAnySubStringsBetweenIBQ(pcBound1, pcBound2)
			This.RemoveAnySubStringsBetweenIB(pcBound1, pcBound2)
			return This

	#--

	def RemoveSubStringsBoundedByIB(pcBound1, pcBound2)
		This.RemoveAnyBetweenIB(pcBound1, pcBound2)

		def RemoveSubStringsBoundedByIBQ(pcBound1, pcBound2)
			This.RemoveSubStringsBoundedByIB(pcBound1, pcBound2)
			return This

	def RemoveAnySubStringBoundedByIB(pcBound1, pcBound2)
		This.RemoveAnyBetweenIB(pcBound1, pcBound2)

		def RemoveAnySubStringBoundedByIBQ(pcBound1, pcBound2)
			This.RemoveAnySubStringBoundedByIB(pcBound1, pcBound2)
			return This

	def RemoveAnySubStringsBoundedByIB(pcBound1, pcBound2)
		This.RemoveAnyBetweenIB(pcBound1, pcBound2)

		def RemoveAnySubStringsBoundedByIBQ(pcBound1, pcBound2)
			This.RemoveAnySubStringsBoundedByIB(pcBound1, pcBound2)
			return This

	#-- Allowing the use of "SECTION" instead of "SUBSTRING"

	def RemoveSectionsBetweenIB(pcBound1, pcBound2)
		This.RemoveAnyBetweenIB(pcBound1, pcBound2)

		def RemoveSectionsBetweenIBQ(pcBound1, pcBound2)
			This.RemoveSectionsBetweenIB(pcBound1, pcBound2)
			return This

	def RemoveAnySectionBetweenIB(pcBound1, pcBound2)
		This.RemoveAnyBetweenIB(pcBound1, pcBound2)

		def RemoveAnySectionBetweenIBQ(pcBound1, pcBound2)
			This.RemoveAnySectionBetweenIB(pcBound1, pcBound2)
			return This

	def RemoveAnySectionsBetweenIB(pcBound1, pcBound2)
		This.RemoveAnyBetweenIB(pcBound1, pcBound2)

		def RemoveAnySectionsBetweenIBQ(pcBound1, pcBound2)
			This.RemoveAnySectionsBetweenIB(pcBound1, pcBound2)
			return This

	#--

	def RemoveSectionsBoundedByIB(pcBound1, pcBound2)
		This.RemoveAnyBetweenIB(pcBound1, pcBound2)

		def RemoveSectionsBoundedByIBQ(pcBound1, pcBound2)
			This.RemoveSectionsBoundedByIB(pcBound1, pcBound2)
			return This

	def RemoveAnySectionBoundedByIB(pcBound1, pcBound2)
		This.RemoveAnyBetweenIB(pcBound1, pcBound2)

		def RemoveAnySectionBoundedByIBQ(pcBound1, pcBound2)
			This.RemoveAnySectionBoundedByIB(pcBound1, pcBound2)
			return This

	def RemoveAnySectionsBoundedByIB(pcBound1, pcBound2)
		This.RemoveAnyBetweenIB(pcBound1, pcBound2)

		def RemoveAnySectionsBoundedByIBQ(pcBound1, pcBound2)
			This.RemoveAnySectionsBoundedByIB(pcBound1, pcBound2)
			return This

	  #-----------------------------------------#
	 #  ALTERNATIVES OF AnyBetweenRemovedIB()  #
	#-----------------------------------------#

	def SubStringsBetweenRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)

	def AnySubStringBetweenRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)

	def AnySubStringsBetweenRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)

	#--

	def AnyBoundedByRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)

	def SubStringsBoundedByRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)

	def AnySubStringBoundedByRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)

	def AnySubStringsBoundedByRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)

	#-- Allowing the use of "SECTION" instead of "SUBSTRING"

	def AnySectionBetweenRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)

	def AnySectionsBetweenRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)

	#--

	def SectionsBoundedByRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)

	def AnySectionBoundedByRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)

	def AnySectionsBoundedByRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)
		return This.AnyBetweenRemovedIBCS(pcBound1, pcBound2, pCaseSensitive)

