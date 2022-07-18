load "stzlib.ring"

/*
	1. FindAll()
	2. FindNth()
	3. FindNext()
	4. FindBetween()
	5. FindWhere()

	FUTURE

	6. DeepFind()
	7. FindPattern()
	8. FindParts()
	9. FindExcept()
*/

o1 = new stzString("bla bla <<word>> bla <<word>> bla <<noword>>")*

#------------------------------#
#  FINDING A GIVEN SUBSTRING   #
#------------------------------#

#-- RETURNING POSITIONS

? o1.FindPositions(:Of = "word")
	? o1.FindAll("word")
	? o1.FindOccurrences(:Of = "word")
	? o1.FindAllOccurrences(:Of = "word")
	? o1.FindAllPositions(:Of = "word")
	? o1.FindPositionsOfOccurrences(:Of = "word")
	? o1.FindPositionsOfAllOccurrences(:Of = "word")

#-- RETURNING SECTIONS

? o1.FindSections(:Of = "word")
	? o1.FindAllSections("word")
	? o1.FindOccurrences(:Of = "word")
	? o1.FindSectionsOfOccurrences(:Of = "word")
	? o1.FindSectionsOfAllOccurrences(:Of = "word")

#----------------------------------------------------#
#  FINDING THE NTH OCCURRENCE OF A GIVEN SUBSTRING   #
#----------------------------------------------------#

#-- RETURNING POSITIONS

? o1.FindNth(2, "word")
	? o1.FindNthOccurrence(2, :Of = "word")
	? o1.FindPositionOfNth(2, "word")
	? o1.FindPositionOfNthOccurrence(2, :Of = "word")

#-- RETURNING SECTIONS

? o1.FindSectionOfNth(2, "word")
	? o1.FindSectionOfNthOccurrence(2, :Of = "word")

#----------------------------------------------------------------------------------------#
#  FINDINGING THE NEXT NTH OCCURRENCE OF A GIVEN SUBSTRING STARTING AT A GIVEN POSITION  #
#----------------------------------------------------------------------------------------#

#-- RETURNING POSITIONS

? o1.FindNextNth("word", :StartingAt = 10)
	? o1.FindNextNthOccurrence(:Of = "word", :StartingAt = 10)

	? o1.FindPositionOfNextNth("word", :StartingAt = 10)
		? o1.FindPositionOfNextNthOccurrence(:Of = "word", :StartingAt = 10)

? o1.FindPreviousNth("word", :StartingAt = 10)
	? o1.FindPreviousNthOccurrence(:Of = "word", :StartingAt = 10)

	? o1.FindPositionOfPreviousNth("word", :StartingAt = 10)
		? o1.FindPositionOfPreviousNthOccurrence(:Of = "word", :StartingAt = 10)

#-- RETURNING SECTIONS

? o1.FindSectionOfNextNth("word", :StartingAt = 10)
	? o1.FindSectionOfNextNthOccurrence(:Of = "word", :StartingAt = 10)

? o1.FindSectionOfPreviousNth("word", :StartingAt = 10)
	? o1.FindSectionOfPreviousNthOccurrence(:Of = "word", :StartingAt = 10)

#-------------------------------------------------------------------------#
#  FINDING OCCURRENCES OF A GIVEN SUBSTRING BETWEEN TWO GIVEN SUBSTRINGS  #
#-------------------------------------------------------------------------#

#-- RETURNING POSITIONS

? o1.FindBetween("word", "<<", ">>")
	? o1.FindSubStringBetween("word", "<<", ">>")
	? o1.FindThisSubStringBetween("word", "<<", ">>")
	? o1.FindPositionsBetween("word", "<<", ">>")
	? o1.FindPositionsOfSubStringBetween("word", "<<", ">>")
	? o1.FindPositionsOfThisSubStringBetween("word", "<<", ">>")

#-- RETURNING SECTIONS

? o1.FindSectionsBetween("word", "<<", ">>")
	? o1.FindSectionsOfSubStringBetween("word", "<<", ">>")
	? o1.FindSectionsOfThisSubStringBetween("word", "<<", ">>")

#-----------------------------------------------------------------#
#  FINDING ANY SUBSTRINGS ENCOLOSED BETWEEN TWO OTHER SUBSTRINGS  #
#-----------------------------------------------------------------#

#-- RETURNING POSITIONS

? o1.FindAnyBetween("<<", ">>")
	? o1.FindAnySubStringBetween("word", "<<", ">>")
	? o1.FindPositionsOfAnySubStringBetween("word", "<<", ">>")

#-- RETURNING SECTIONS

? o1.FindAnySectionsBetween("<<", ">>")
	? o1.FindSectionsOfAnySubStringBetween("<<", ">>")

#--------------------------------------------------#
#  FINDING SUBSTRINGS VERIFYING A GIVEN CONDITION  #
#--------------------------------------------------#

#-- RETURNING POSITIONS

? o1.FindWhere(' @SubString = "word" ')
	? o1.FindPositionsW(' @SubString = "word" ')

#-- RETURNING SECTIONS

? o1.FindSectionsWhere(' @SubString = "word" ')

#---------------------------------------------#
#  REPLACING A SUBSTRING AT A GIVEN POSITION  #
#---------------------------------------------#

#-- GENERAL FORM

	o1.ReplaceAt(5, "word", :With = "newword")
	#--> o1.ReplaceAtPosition(5, "word", :With = "newword")
	
	o1.ReplaceAt([5, 12], "word", :With = "newword")
	#--> o1.ReplaceAtSection([5, 12], "word", :With = "newword")
	
	o1.ReplaceAt([5, 8, 12], "word", :With = "newword")
	#--> o1.ReplaceAtPositions([5, 8, 12], "word", :With = "newword")
	
	o1.ReplaceAt([ [5, 12], [20, 34] ], "word", :With = "newword")
	#--> o1.ReplaceAtSections([ [5, 12], [20, 34] ], "word", :With = "newword")

#-- USING POSITIONS

	o1.ReplaceSubStringAtPosition(5, "word", :With = "newword" )
		o1.ReplaceAtPosition(5, "word", :With = "newword" )
	
	o1.ReplaceSubStringAtPositions([ 5, 12, 21 ], "word", :With = "newword" )
		o1.ReplaceAtPositions([ 5, 12, 21 ], "word", :With = "newword" )

#-- USING SECTIONS

	o1.ReplaceSubStringAtSection([5, 8], :With = "newword")
		o1.ReplaceSection([5, 8], :With = "newword")
	
	o1.ReplaceSubStringAtSections([ [5, 8], [12, 15], [21, 23] ], :With = "newword" )
		o1.ReplaceSections( [ [5, 8], [12, 15], [21, 23] ], :With = "newword" )

#--------------------------------------------#
#  REMOVING A SUBSTRING AT A GIVEN POSITION  #
#--------------------------------------------#

#-- GENERAL FORM

	o1.RemoveAt(5, "word")
	#--> o1.RemoveAtPosition(5, "word")
	
	o1.RemoveAt([5, 12], "word")
	#--> o1.RemoveAtSection([5, 12], "word")
	
	o1.RemoveAt([5, 8, 12], "word")
	#--> o1.RemoveAtPositions([5, 8, 12], "word")
	
	o1.RemoveAt([ [5, 12], [20, 34] ], "word")
	#--> o1.InsertAtSections([ [5, 12], [20, 34] ], "word")

#-- USING POSITIONS

	o1.RemoveSubStringAtPosition(5, "word")
		o1.RemoveAtPosition(5, "word")
	
	o1.RemoveSubStringAtPositions([ 5, 12, 21 ], "word")
		o1.RemoveAtPositions([ 5, 12, 21 ], "word")

#-- USING SECTIONS

	o1.RemoveSubStringAtSection([5, 8])
		o1.RemoveSection([5, 8])
	
	o1.RemoveSubStringAtSections([ [5, 8], [12, 15], [21, 23] ])
		o1.RemoveSections( [ [5, 8], [12, 15], [21, 23] ] )

#---------------------------------------------#
#  INSERTING A SUBSTRING AT A GIVEN POSITION  #
#---------------------------------------------#

#-- GENERAL FORM

	o1.InsertAt(5, "word")
	#--> o1.InsertAtPosition(5, "word")
	
	o1.InsertAt([5, 12], "word")
	#-->	o1.InsertAtSection([5, 12], "word")
	
	o1.InsertAt([5, 8, 12], "word")
	#--> o1.InsertAtPositions([5, 8, 12], "word")
	
	o1.InsertAt([ [5, 12], [20, 34] ], "word")
	#-->	o1.InsertAtSections([ [5, 12], [20, 34] ], "word")

#-- USING POSITIONS

	o1.InsertSubStringAtPosition(5, "word")
		o1.InsertAtPosition(5, "word")
	
	o1.InsertSubStringAtPositions([5, 12, 21], "word")
		o1.InsertAtPositions([5, 12, 21], "word")

#-- USING SECTIONS

	o1.InsertSubStringAtSection([5, 12], "word")
		o1.InsertAtSections([5, 12], "word")
	
	o1.InsertSubStringAtPositions([ [5, 12], [16, 21] ], "word")
		o1.InsertAtPositions([ [5, 12], [16, 21] ], "word")
