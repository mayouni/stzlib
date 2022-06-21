load "stzlib.ring"

# LESSON 	: THE ART OF REPLACING SUBSTRINGS IN A LIST OF STRINGS IN SOFTANZA
# OBJECTIVE	: PRACTICING MORE THEN 60 WAYS OF REPLACING SUBSTRINGS IN A LIST OF STRINGS
# DURATION	: 20 MINUTES

/*
#------------#
#   CONTENT  #
#------------#

	A. REPLACING ALL OCCURRENCES OF SUBSTRINGS
	B. REPLACING SUBSTRINGS AT POSITIONS (CROSS-STRINGS)
	C. REPLACING SUBSTRINGS IN STRINGS-AT-POSITIONS 
	D. REPLACING OCCURRENCES OF SUBSTRINGS (CROSS-STRINGS)
	E. REPLACING OCCURRENCES OF SUBSTRINGS IN STRING(S) AT POSITION(S)
	F. REPLACING NEXT OCCURRENCES STARTING AT A GIVEN POSITION OR OCCURRENCE
	G. REPLACING PREVIOUS OCCURRENCES STARTING AT A GIVEN PSOTION OR OCCURRENCE
	H. REPLACING SUBSRRINGS WITH A DYNAMIC VALUE
	I. CONDITIONAL REPLACEMENT OF SUBSTRINGS

#----------------------------------------------#
#  A. REPLACING ALL OCCURRENCES OF SUBSTRINGS  #
#----------------------------------------------#
*/
	#-- 1. REPLACING ALL OCCURRENCES OF A SUBSTRING BY A NEW SUBSTRING
/*
		o1 = new stzListOfStrings([ "heart ipsum heart", "lorem heart", "heart" ])
		o1.ReplaceSubString("heart", :With = "♥")
	
		? o1.Content() #--> [ "♥ ipsum", "lorem ♥", "♥" ]

		#-- CASE OF DYNAMIC VALUE

		IconOf = [ :Heart = "♥" ]

		o1 = new stzListOfStrings([ "heart ipsum", "lorem heart", "heart" ])
		o1.ReplaceSubString("heart", :With@ = 'IconOf[@SubString]')
		
		? @@( o1.Content() ) #--> [ "♥ ipsum", "lorem ♥", "♥" ]

/*
*/
	#-- 2. REPLACING SUBSTRING BY MANY SUBSTRINGS
/*
*/
		o1 = new stzListOfStrings(["heart ___ heart", "___ heart ___ heart ___ heart", "heart"])
		//o1.ReplaceSubStringByMany("heart", :With = [ "♥1", "♥2", "♥3", "♥1", "♥2", "♥3" ])
		o1.ReplaceSubStringByMany("heart", :With = L('{ "♥1" : "♥3" }'))
//		? o1.Content() #--> [ "♥1 ipsum ♥2", "lorem ♥3 ipsum ♥4 lorem ♥5", "♥6" ]

STOP	
	#-- 3. REPLACING SUBSTRING BY MANY SUBSTRING -- EXTENDED
/*
		o1 = new stzListOfStrings(["heart ipsum heart", "lorem heart ipsum heart lorem heart", "heart"])
		o1.ReplaceSubStringByManyXT("heart", :With = L('{ "♥1" : "♥3" }'))
		? o1.Content() #--> [ "♥1 ipsum ♥2", "lorem ♥1 ipsum ♥2 lorem ♥3", "♥3" ]

STOP
	#-- 4. REPLACING MANY SUBSTRINGS BY A GIVEN VALUE
	
		o1 = new stzListOfStrings([ "one ipsum two", "lorem one ipsum three", "three" ])
		o1.ReplaceManySubStrings([ "one", "two", "three" ], :With = "♥" )

		? @@( o1.Content() ) #--> [ "♥ ipsum ♥", "lorem ♥ ipsum ♥", "♥" ]

		#--> Todo: Dynamic Value

		Numbers = [ "1", "2", "3"]

		o1 = new stzListOfStrings([ "one ipsum two", "lorem one ipsum three", "three" ])
		o1.ReplaceManySubStrings([ "one", "two", "three" ], :With@ = 'Numbers[@i]' )

		? @@( o1.Content() ) #--> [ "1 ipsum 2", "lorem 1 ipsum 3", "3" ]


/*
	
	#-- 4. REPLACING SUBSTRINGS BY MANY OTHERS
*/


		o1 = new stzListOfStrings([ "one ipsum two", "lorem one ipsum three", "three" ])
		o1.ReplaceSubStringsByMany([ "one", "two", "three" ], :With = [ "1", "2", "3" ])

		? @@( o1.Content() ) #--> 

/*
	6.	ReplaceSubStringsByManyXT(pacSubStrings, pacNewSubStrings)

#--------------------------------------------------------#
#  B. REPLACING SUBSTRINGS AT POSITIONS (CROSS-STRINGS)  #
#--------------------------------------------------------#


#----------------------------------------------------#
#  C. REPLACING SUBSTRINGS IN STRINGS-AT-POSITIONS   #
#----------------------------------------------------#

	#-- 1. REPLACING, INSIDE A GIVEN STRING, ALL THE OCCURRENCES OF A GIVEN SUBSTRING

	o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])
	o1.ReplaceInStringN(2, "ring", :With = "♥")
	? o1.Content()
	#--> [ "php", "♥ php ♥ python ♥", "python" ]

	#-- 2. REPLACING, INSIDE A GIVEN STRING, A SUBSTRING AT A GIVEN POSITION

	o1 = new stzListOfStrings([ "php", "php ring python", "python" ])
	o1.ReplaceInStringNSubstringAtPositionN(2, 5, "ring", :With = "♥" )
	? o1.Content()
	#--> [ "php", "php ♥ python", "python" ]

	#-- 3. REPLACING, INSIDE A GIVEN STRING, THE NTH OCCURRENCE OF A GIVEN SUBSTRING

	#-- 4. REPLACING, INSIDE A GIVEN STRING, THE FIRST OCCURRENCE OF A GIVEN SUBSTRING

	#-- 5. REPLACING, INSIDE A GIVEN STRING, THE LAST OCCURRENCE OF A GIVEN SUBSTRING
