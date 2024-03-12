load "stzlib.ring"

# LESSON 	: THE ART OF REPLACING SUBSTRINGS IN SOFTANZA STRINGS
# OBJECTIVE	: PRACTICING 21 WAYS OF REPLACING SUBSTRINGS
# DURATION	: 5 MINUTES

/*
#------------#
#   CONTENT  #
#------------#

	A)- Introduction: COMPLETENESS as a design goal in Softanza
	B)- General (four) uses cases in replacing substrings
	C)- Cases of replacing SOME occurrences ONLY of a substring
	D)- Cases of replacing substrings AT GIVEN POSITIONS inside the string
	E)- Cases where MANY substrings are involved in the replacement operation
	F)- Cases of replacing a substring BETWEEN two buonding substrings 
	G)- Cases of replacing the NTH occurrence of a substring
	H)- Cases of replacing NEXT/PREVIOUS nth occurrence of a substring
	I)- Two more use cases, for maximum freedom:
	    DYNAMIC and CONDITIONAL replacement of substrings! 

#--------------------------------------------------#
#  A. INTRODUCTION: COMPLETENESS AS A DESIGN GOAL  #
#--------------------------------------------------#

	One of the design goals of Softanza is COMPLETENESS.

	This means that the library tries to provide a SYSTEMATIC solution
	to any problem, covering "all" the possible cases you could face in practice.

	To show it by example, let's take the substring replacement feature in
	stzString, made using the Replace() function.

/*--	In its simplest form, we can use it like this:
*/
		o1 = new stzString("ring php ruby ring python ring")
		o1.Replace("ring", :With = "♥♥♥")
	
		? o1.Content() #--> "♥♥♥ php ruby ♥♥♥ python ♥♥♥"


/*	From a programmer-experience perspective, there are many other scenarios that
	are not covered directly by the previous function. This is just one of them:

	- What if we want to replace the occurrences of "ring" with many substrings,
	something like this for example:

		o1 = new stzString("ring php ruby ring python ring")
		o1.ReplaceByMany("ring", :With = [ "♥", "♥♥", "♥♥♥" ])
	
		? o1.Content() #--> "♥ php ruby ♥♥ python ♥♥♥"

#----------------------------------------------------#
#  B)- GENERAL 4 USE CASES IN REPLACING SUBSTRINGS   #
#----------------------------------------------------#

	Hence, a general solution should be provided, so we can come with a direct
	solution to any possible situation.

	To do so, we built a bunch of functions based on the follwing logic:

			     +---------------------------+-----------------------------------+
	      REPLACE        |       A SUBSTRING         |          MANY SUBSTRINGS          |
	+====================+===========================+===================================+
	|       BY A         |           (1)             |               (2)                 |
	|     SUBSTRING      | Replace(substr1, substr2) | ReplaceMany(acSubStr, substr) |
	+--------------------+---------------------------+-----------------------------------+
	|        BY          |            (3)            |               (4)                 |
	|       MANY         | ReplaceByMany(substr,     | ReplaceManyByMany(acSubStr,   |
	|     SUBSTRINGS     |          acSubStr)    |          acOtherSubStrings)       |
	+--------------------+---------------------------+-----------------------------------+

	The scenario number (1) has been presented by the example above. Let's reproduce it
	again and illustrate the use of the other functions as well:

/*--	(1) REPLACING A SUBSTRING BY AN OTHER SUBSTRING

		o1 = new stzString("ring php ruby ring python ring")
		o1.Replace("ring", :By = "♥♥♥")
	
		? o1.Content() #--> "♥♥♥ php ruby ♥♥♥ python ♥♥♥"

/*--	(2) REPLACING MANY SUBSTRINGS BY A SUBSTRING

		o1 = new stzString("ring php ring pyhthon ring ruby softanza")
		o1.ReplaceMany([ "ring", "ringqt", "softanza" ], :By = "♥♥♥" )

		? o1.Content() #--> "♥♥♥ php ♥♥♥ pyhthon ♥♥♥ ruby ♥♥♥"

/*--	(3) REPLACING A SUBSTRING BY MANY SUBSTRINGS

		o1 = new stzString("ring php ruby ring python ring")
		o1.ReplaceByMany("ring", [ "♥", "♥♥", "♥♥♥" ])
	
		? o1.Content() #--> "♥ php ruby ♥♥ python ♥♥♥"

/*--	(4) REPLACING MANY SUBSTRINGS BY MANY OTHER SUBSTRINGS

		o1 = new stzString("ring qt softanza pyhton kandaji csharp ring")
		o1.ReplaceManyByMany([ "ring", "softanza", "kandaji" ], :By = [ "♥", "♥♥", "♥♥♥" ])

		? o1.Content() #--> "♥ qt ♥♥ pyhton ♥♥♥ csharp ♥"

#-------------------------------------------------------------#
#  C)- CASES OF REPLACING "SOME" OCCURRENCES OF A SUBSTRING   #
#-------------------------------------------------------------#

	The cases covered so far peform the replacement of ALL the occurrence of the
	given substrings. What if wa want to replace just some occurrences of them?

	To do so, two other functions are provided based on this logic:

			     +----------------------------------------------------------+
	      REPLACE        |             SOME OCCURRENCES OF A SUBSTRING              |
	+====================+==========================================================+
	|       BY A         |                          (5)                             |
	|     SUBSTRING      |    ReplaceSome(panOccurrences, cSubStr, cNewSubStr)      | 
	+--------------------+----------------------------------------------------------+
	|      BY MANY       |                          (6)                             |
	|    SUBSTRINGS      | ReplaceSomeByMany(panOccurrences, cSubStr, acSubStr) |
	+--------------------+----------------------------------------------------------+

	Let's illstrate those two scnearios with examples:

/*--	(5) REPLACING SOME OCCURRENCES OF A SUBSTRING BY AN OTHER SUBSTRING

		o1 = new stzString("ring php ring ruby ring python ring csharp ring")
		o1.ReplaceSome([ 1, 5], "ring", :By = "♥♥♥")
	
		? o1.Content() #--> "♥♥♥ php ring ruby ring python ring csharp ♥♥♥"

/*--	(6) REPLACING SOME OCCURRENCES OF A SUBSTRING BY MANY OTHER STRINGS

		o1 = new stzString("ring php ring ruby ring python ring csharp ring")
		o1.ReplaceSomeByMany([ 1, 3, 5], "ring", :By = [ "#1", "#3", "#5" ])
	
		? o1.Content() #--> "#1 php ring ruby #3 python ring csharp #5"

#----------------------------------------------------------------------------#
#  D)- CASES OF REPLACING SUBSTRINGS "AT GIVEN POSITIONS" INSIDE THE STRING  #
#----------------------------------------------------------------------------#

	Now, what if you need to replace substrings by specifying their positions inside
/*--	the string, something like this:

		o1 = new stzString("ring php ring pyhton ring ruby ring")
		o1.ReplaceSubStringAtPositions([ 1, 10, 32 ], "ring", :By = "♥")

		? o1.Content() #--> "♥ php ♥ pyhton ring ruby ♥"

/*	Again, we think on it systematically by implementing the following set of functions:

			          +----------------------------------------------------------------------+
	          REPLACE         |                            A SUBSTRING                               |
	+=========================+======================================================================+
	|   AT A GIVEN POSITION   |                                (7)                                   |
	|     BY A SUBSTRING      |          ReplaceSubStringAtPosition(n, pcSubStr, pcNewSubStr)        | 
	+-------------------------+----------------------------------------------------------------------+
	| AT SOME GIVEN POSITIONS |                                (8)                                   |
	|     BY A SUBSTRING      |     ReplaceSubStringAtPositions(panPositions, substr, pcNewSubStr)   |
	+-------------------------+----------------------------------------------------------------------+
	| AT SOME GIVEN POSITIONS |                                (9)                                   |
	|    BY MANY SUBSTRINGS   | ReplaceSubStringAtPositionsByMany(panPositions, substr, pacNewSubStr)|
	+-------------------------+----------------------------------------------------------------------+

	These are the corresponding examples of the 3 scenarios above:

/*--	(7) REPLACING A SUBSTRING AT A GIVEN POSITION BY AN OTHER SUBSTRING

		o1 = new stzString("ring ruby ring php ring")
		o1.ReplaceSubstringAtPosition(11, "ring", :By = "♥♥♥")

		? o1.Content() #--> "ring ruby ♥♥♥ php ring"

/*--	(8) REPLACING A SUBSTRING AT A SOME GIVEN POSITIONS BY AN OTHER SUBSTRING

		o1 = new stzString("ring ruby ring php ring")
		o1.ReplaceSubstringAtPositions([ 1, 20], "ring", :By = "♥♥♥")

		? o1.Content() #--> "♥♥♥ ruby ring php ♥♥♥"

/*--	(9) REPLACING A SUBSTRING AT A SOME GIVEN POSITIONS BY MANY OTHER SUBSTRINGS

		o1 = new stzString("ring php ring ruby ring python ring csharp ring")
		o1.ReplaceSubstringAtPositionsByMany([ 10, 20, 32], "ring", :By = [ "♥", "♥♥", "♥♥♥" ])

		? o1.Content() #--> "ring php ♥ ruby ♥♥ python ♥♥♥ csharp ring"

#-------------------------------------------------#
#  E)- CASES WHEN "MANY" SUBSTRINGS ARE ENVLOVED  #
#-------------------------------------------------#
/*
	Everytime many substrings are to be replaced by many others, three cases can be faced.
	Let's present them by example.

/*--		# Case 1: The number of new substrings is equal to the number of substrings
		  to be replaced (already done but let's look at i again):
		
		o1 = new stzString("ring php ring ruby ring python")
		o1.ReplaceByMany("ring", :By = [ "♥", "♥♥", "♥♥♥" ])

		? o1.Content() #--> "♥ php ♥♥ ruby ♥♥♥ python"

/*--	In this example, an all the examples above involving many substrings, we have as mutch
	new substrings as occurrences of "ring" on the string. The replacement operation is
	then straightforward: the 1st occurrence of "ring" takes the 1st new substring "♥",
	the 2nd takes "♥♥" and 3rd takes "♥♥♥"...

	Now: What if more then 3 new substrings are provided?
	Well: They are simply igonored:

/*--		# Case 2: More new substrings then the number of occurrences of
		  the substring inside the string

		o1 = new stzString("ring php ring ruby ring python")
		o1.ReplaceByMany("ring", :By = [ "♥", "♥♥", "♥♥♥", "♥♥♥♥", "♥♥♥♥♥" ])

		? o1.Content() #--> "♥ php ♥♥ ruby ♥♥♥ python"

/*--	But when they are 2, for example (less than 3), then only the first two
	occurrences of "ring" are replaced:

/*--		# Case 3: Less new substrings then the number of occurrences of
		  the substring inside the string

		o1 = new stzString("ring php ring ruby ring python")
		o1.ReplaceByMany("ring", :By = [ "♥", "♥♥" ])

		? o1.Content() #--> "♥ php ♥♥ ruby ring python"

/*--	In this particular case (when the number of new substrings is lesser then the
	number of occurrences of "ring" in the string), you have the possibility to
	instruct Softanza so it continues replacing all the occurrences of "ring"
	by restarting at the first new substring provided, using the XT() extension,
	like this:

/*--	(10) REPLACING A SUBSTRING BY MANY OTHER SUBSTRINGS -- EXTENDED (RESTART AT FIRST)

		o1 = new stzString("ring php ring ruby ring python ring")
		o1.ReplaceByManyXT("ring", :By = [ "#1", "#2" ])

		? o1.Content() #--> "#1 php #2 ruby #1 python #2"

#--------------------------------------------------------#
#  F)- CASES OF A SUBSTRING BETWEEN TWO GIVEN SUBSTRINGS  #
#--------------------------------------------------------#

	In practice, you can be faced with the situation where you need to replace
	a substring bounded by two other substrings. In Softanza, you are coverd:

/*--	(11) REPLACING A GIVEN SUBSTRING BETWEEN TWO OTHER SUBSTRINGS

	o1 = new stzString("bla bla <<ring>> bla bla <<ring>> bla <<ring>>")
	o1.ReplaceBetween("ring", "<<", ">>", :With = "♥♥♥")
	? o1.Content() #--> bla bla <<♥♥♥>> bla bla <<♥♥♥>> bla <<♥♥♥>>
	

/*	Or may you need to replace, not a specific substring, but ANY one bounded
	by two other substrings:

/*--	(12) REPLACING ANY SUBSTRING BETWEEN TWO OTHER SUBSTRINGS

	o1 = new stzString("bla bla <<ring>> bla bla <<ruby>> bla <<python>>")
	o1.ReplaceAnyBetween("<<", ">>", :With = "♥♥♥")
	? o1.Content() #--> bla bla <<♥♥♥>> bla bla <<♥♥♥>> bla <<♥♥♥>>

#--------------------------------------------------------------#
#  G)- CASES OF REPLACING THE "NTH" OCCURRENCE OF A SUBSTRING  #
#--------------------------------------------------------------#

	One of the amazing gymnastics provided to you in Softanza, is that you can
	jump directly to the nth occurrence of a substring in the string, or walk in
	any direction (foreward or backward) to position yourself on the NEXT or
	PREVIOUS occurrence (or even nth occurrence!) of a given substring!

	Let's see how easy it is to perform all of that...

/*--	(13) REPLACING THE NTH OCCURRENCE OF A SUBSTRING

	o1 = new stzString("ring php ring ruby ring python ring")
	o1.ReplaceNthOccurrence( 3, :Of = "ring", :by = "♥♥♥" )

	? o1.Content() #--> ring php ring ruby ♥♥♥ python ring

/*--	(14) REPLACING FIRST OCCURRENCE OF A SUBSTRING

	o1 = new stzString("ring php ring ruby ring python ring")
	o1.ReplaceFirstOccurrence( :Of = "ring", :by = "♥♥♥" )

	? o1.Content() #--> ♥♥♥ php ring ruby ring python ring

/*--	(15) REPLACING LAST OCCURRENCE OF A SUBSTRING

	o1 = new stzString("ring php ring ruby ring python ring")
	o1.ReplaceLastOccurrence( :Of = "ring", :by = "♥♥♥" )

	? o1.Content() #--> ring php ring ruby ring python ♥♥♥

#-------------------------------------------------------#
#  H)- CASES OF REPLACING NEXT/PREVIOUS NTH OCCURRENCE  #
#-------------------------------------------------------#

/*--	(16) REPLACING NEXT "NTH" OCCURRENCE OF A SUBSTRING STARTING
	     AT A GIVEN OCCURRENCE

	o1 = new stzString("ring php ring ruby ring python ring")
	o1.ReplaceNextNthOccurrence(2, :Of = "ring", :StartingAtOccurrence = 2, :By = "♥♥♥")

	? o1.Content() #--> ring php ring ruby ring python ♥♥♥

/*--	(17) REPLACING NEXT "NTH" OCCURRENCE OF A SUBSTRING STARTING
	     AT A GIVEN POSITION

	o1 = new stzString("ring php ring ruby ring python ring")
	o1.ReplaceNextNthOccurrence(2, :Of = "ring", :StartingAtPosition = 2, :By = "♥♥♥")
	# or you can say :StartingAt = 2 instead of :StartingAtPosition

	? o1.Content() #--> ring php ring ruby ♥♥♥ python ring

/*--	(18) REPLACING NEXT OCCURRENCE OF A SUBSTRING STARTING
	     AT A GIVEN OCCURRENCE

	o1 = new stzString("ring php ring ruby ring python ring")
	o1.ReplaceNextOccurrence(:Of = "ring", :StartingAtOccurrence = 2, :By = "♥♥♥")

	? o1.Content() #--> ring php ring ruby ♥♥♥ python ring

/*--	(19) REPLACING NEXT OCCURRENCE OF A SUBSTRING STARTING
	     AT A GIVEN POSITION

	o1 = new stzString("ring php ring ruby ring python ring")
	o1.ReplaceNextOccurrence(:Of = "ring", :StartingAtPosition = 2, :By = "♥♥♥")
	# or you can say :StartingAt = 2 instead of :StartingAtPosition

	? o1.Content() #--> ring php ring ruby ♥♥♥ python ring

/*--	(16) REPLACING PREVIOUS "NTH" OCCURRENCE OF A SUBSTRING STARTING
	     AT A GIVEN OCCURRENCE

	o1 = new stzString("ring php ring ruby ring python ring")
	o1.ReplacePreviousNthOccurrence(2, :Of = "ring", :StartingAtOccurrence = 3, :By = "♥♥♥")

	? o1.Content() #--> ♥♥♥ php ring ruby ring python ring

/*--	(17) REPLACING PREVIOUS "NTH" OCCURRENCE OF A SUBSTRING STARTING
	     AT A GIVEN POSITION

	o1 = new stzString("ring php ring ruby ring python ring")
	o1.ReplacePreviousNthOccurrence(3, :Of = "ring", :StartingAtPosition = 25, :By = "♥♥♥")
	# or you can say :StartingAt = 2 instead of :StartingAtPosition

	? o1.Content() #--> ♥♥♥ php ring ruby ring python ring

/*--	(18) REPLACING PREVIOUS OCCURRENCE OF A SUBSTRING STARTING
	     AT A GIVEN OCCURRENCE

	o1 = new stzString("ring php ring ruby ring python ring")
	o1.ReplacePreviousOccurrence(:Of = "ring", :StartingAtOccurrence = 2, :By = "♥♥♥")

	? o1.Content() #--> ♥♥♥ php ring ruby ring python ring

/*--	(19) REPLACING PREVIOUS OCCURRENCE OF A SUBSTRING STARTING
	     AT A GIVEN POSITION

	o1 = new stzString("ring php ring ruby ring python ring")
	o1.ReplacePreviousOccurrence(:Of = "ring", :StartingAtPosition = 25, :By = "♥♥♥")
	# or you can say :StartingAt = 2 instead of :StartingAtPosition

	? o1.Content() #--> ring php ring ruby ♥♥♥ python ring
	
#--------------------------------------------------------------------------------#
#  I) TWO MORE CASES, FOR MAXIMUM FREEDOM: DYNAMIC AND CONDITIONAL REPLACEMENT!  #
#--------------------------------------------------------------------------------#

/*	To cover other situations you may think of, and before writing specific Ring
	code to solve it, check these last two Softanza features (13 & 14):

/*--	(20) REPLACING A SUBSTRING WITH A DYNAMIC VALUE (using With@ or :By@)

		o1 = new stzString("ring php ring ruby ring pyhton ring")
		o1.ReplaceSubString( "ring", :By@ = '{ "#" + @Occurrence }' )

		? o1.Content() #--> "#1 php #2 ruby #3 pyhton #4"

/*--	(21) REPLACING A SUBSTRING UNDER A GIVEN CONDITION

		o1 = new stzString("ring php ring ruby ring pyhton ring")
		o1.ReplaceSubStringW("ring", :Where = '{ Q(@Position).IsMultipleOf(10) }', :With = "♥♥♥")

		? o1.Content() #--> "ring php ♥♥♥ ruby ♥♥♥ pyhton ring"

/*--		In fact, the 2nd and 3rd occurrences of "ring" occupy respectively the positions 10 and 20,
		Which are both multiple of 10.
	
*/

 
