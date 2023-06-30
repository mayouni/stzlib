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
	G. REPLACING PREVIOUS OCCURRENCES STARTING AT A GIVEN POSITION OR OCCURRENCE
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
		
		? o1.Content() #--> [ "♥ ipsum", "lorem ♥", "♥" ]

	#-- 2. REPLACING SUBSTRING BY MANY SUBSTRINGS
/*
		o1 = new stzListOfStrings(["heart ___ heart", "___ heart ___ heart ___ heart", "heart"])
		o1.ReplaceSubStringByMany("heart", :With = L('{ "♥1" : "♥3" }'))
		? o1.Content() #--> [ "♥1 ___ ♥2", "___ ♥3 ___ heart ___ heart", "heart" ]
	
		#-- CASE OF DYNAMIC VALUE

		c3Hearts = "♥1♥2♥3"

		o1 = new stzListOfStrings(["heart ___ heart", "___ heart ___ heart ___ heart", "heart"])
		o1.ReplaceSubStringByMany( "heart", :With@ = '{ Q(c3Hearts) / 3 }' )
		? o1.Content() #--> [ "♥1 ___ ♥2", "___ ♥3 ___ heart ___ heart", "heart" ]
	
	#-- 3. REPLACING SUBSTRING BY MANY SUBSTRING -- EXTENDED
/*
		o1 = new stzListOfStrings(["heart ___ heart", "___ heart ___ heart ___ heart", "heart"])
		o1.ReplaceSubStringByManyXT("heart", :With = L('{ "♥1" : "♥3" }'))
		? o1.Content() #--> [ "♥1 ___ ♥2", "___ ♥3 ____ ♥1 ____ ♥2", "♥3" ]

		#-- CASE OF DYNAMIC VALUE

		c3Hearts = "♥1♥2♥3"

		o1 = new stzListOfStrings(["heart ___ heart", "___ heart ___ heart ___ heart", "heart"])
		o1.ReplaceSubStringByManyXT( "heart", :With@ = '{ Q(c3Hearts) / 3 }' )
		? o1.Content() #--> [ "♥1 ___ ♥2", "___ ♥3 ____ ♥1 ____ ♥2", "♥3" ]

	#-- 4. REPLACING MANY SUBSTRINGS BY A GIVEN VALUE
/*	
		o1 = new stzListOfStrings([ "one ___ two", "___ one ___ three", "three" ])
		o1.ReplaceManySubStrings([ "one", "two", "three" ], :With = "♥" )

		? o1.Content() #--> [ "♥ ___ ♥", "___ ♥ ___ ♥", "♥" ]

		#-- CASE OF DYNAMIC VALUE

		Numbers = [ "1", "2", "3"]

		o1 = new stzListOfStrings([ "one ___ two", "___ one ___ three", "three" ])
		o1.ReplaceManySubStrings([ "one", "two", "three" ], :With@ = '{ Numbers[@i] }' )

		? o1.Content() #--> [ "1 ___ 2", "___ 1 ___ 3", "3" ]

/*
	
	#-- 4. REPLACING SUBSTRINGS BY MANY OTHERS

		o1 = new stzListOfStrings([ "one ___ two", "___ one ___ three", "three" ])
		o1.ReplaceSubStringsByMany([ "one", "two", "three" ], :With = [ "1", "2", "3" ])

		? o1.Content() #--> [ "1 ___ 2", "___ 1 ___ 3", "3" ]

		#-- CASE OF DYNAMIC VALUE

		cNumbers = "123"

		o1 = new stzListOfStrings([ "one ___ two", "___ one ___ three", "three" ])
		o1.ReplaceSubStringsByMany([ "one", "two", "three" ], :With@ = '{ Q(cNumbers) / 3 }' )

		? o1.Content() #--> [ "1 ___ 2", "___ 1 ___ 3", "3" ]

	#-- 5. REPLACING SUBSTRINGS BY MANY OTHERS -- EXTENDED
/*

		o1 = new stzListOfStrings([ "one ___ two", "___ one ___ three", "four ___ three" ])
		o1.ReplaceSubStringsByManyXT([ "one", "two", "three", "four" ], :With = [ "1", "2" ])

		? o1.Content() #--> [ "1 ___ 2", "___ 1 ___ 1", "2 __ 1" ]

		#-- CASE OF DYNAMIC VALUE

		cNumbers = "12"

		o1 = new stzListOfStrings([ "one ___ two", "___ one ___ three", "four ___ three" ])
		o1.ReplaceSubStringsByManyXT([ "one", "two", "three", "four" ], :With@ = '{ Q(cNumbers) / 2 }' )

		? o1.Content() #--> [ "1 ___ 2", "___ 1 ___ 1", "2 __ 1" ]

#-----------------------------------------------#
#  B. REPLACING SUBSTRINGS AT GIVEN POSITIONS   #
#-----------------------------------------------#

	#-- 1. REPLACING A SUBSTRING AT A GIVEN POSITION
/*
		o1 = new stzListOfStrings([ "___ ♥ ___", "♥ ___ ring ___", "♥" ])
		o1.ReplaceSubStringAtPosition( [2, 7], "ring", :With = "♥" )
	
		? o1.Content() #--> [ "___ ♥ ___", "♥ ___ ♥ ___", "♥" ]
	
		# CASE OF DYNAMIC VALUE

		o1 = new stzListOfStrings([ "___ ♥ ___", "♥ ___ ring ___", "♥" ])
		o1.ReplaceSubStringAtPosition( [2, 7], "ring", :With@ = '{ Heart() }' )
	
		? o1.Content() #--> [ "___ ♥ ___", "♥ ___ ♥ ___", "♥" ]

	#-- 2. REPLACING A SUBSTRING AT MANY POSITIONS
/*
		o1 = new stzListOfStrings([ "___ ring ___ ♥", "♥ ___ ring ___", "♥ ___ ring" ])
		o1.ReplaceSubStringAtPositions( [ [1, 5], [2, 7], [3, 7] ], "ring", :With = "♥" )
	
		? o1.Content() #--> [ "___ ♥ ___ ♥", "♥ ___ ♥ ___", "♥ ___ ♥" ]

		#-- CASE OF DYNAMIC VALUE

		o1 = new stzListOfStrings([ "___ ring ___ ♥", "♥ ___ ring ___", "♥ ___ ring" ])
		o1.ReplaceSubStringAtPositions( [ [1, 5], [2, 7], [3, 7] ], "ring", :With@ = '{ Heart() }' )
	
		? o1.Content() #--> [ "___ ♥ ___ ♥", "♥ ___ ♥ ___", "♥ ___ ♥" ]

#-------------------------------------------------#
#  C. REPLACING SUBSTRINGS INSIDE َA GIVEN STRING  #
#-------------------------------------------------#
/*
	#-- 1. REPLACING, INSIDE A GIVEN STRING, ALL THE OCCURRENCES OF A GIVEN SUBSTRING

	o1 = new stzListOfStrings([ "__ ♥ __", "♥ __ ring __ ♥", "__ ♥ __" ])
	o1.ReplaceInStringN(2, "ring", :With = "♥")
	? o1.Content()
	#--> [ "__ ♥ __", "♥ __ ♥ __ ♥", "__ ♥ __" ]

	#-- CASE OF DYNAMIC VALUE

	o1 = new stzListOfStrings([ "__ ♥ __", "♥ __ ring __ ♥", "__ ♥ __" ])
	o1.ReplaceInStringN(2, "ring", :With@ = '{ Heart() }' )
	? o1.Content()
	#--> [ "__ ♥ __", "♥ __ ♥ __ ♥", "__ ♥ __" ]

	#-- 2. REPLACING, INSIDE A GIVEN STRING, THE NTH OCCURRENCE OF A GIVEN SUBSTRING

	o1 = new stzListOfStrings([ "__ ♥ __", "ring __ ring __ ring", "__ ♥ __" ])
	o1.ReplaceInStringNTheNthOccurrence(2, 2, :Of = "ring", :With = "♥")
	? o1.Content() #--> [ "__ ♥ __", "ring __ ♥ __ ring", "__ ♥ __" ]

	# CASE OF DYNAMIC VALUE

	o1 = new stzListOfStrings([ "__ ♥ __", "ring __ ring __ ring", "__ ♥ __" ])
	o1.ReplaceInStringNTheNthOccurrence(2, 2, :Of = "ring", :With@ = '{ Heart() }' )
	? o1.Content() #--> [ "__ ♥ __", "ring __ ♥ __ ring", "__ ♥ __" ]

	#-- 4. REPLACING, INSIDE A GIVEN STRING, THE FIRST N OCCURRENCES OF A GIVEN SUBSTRING
*/
	o1 = new stzListOfStrings([ "__ ♥ __", "ring __ ring __ ring", "__ ♥ __" ])
	o1.ReplaceInStringNTheFirstNOccurrences(2, 2, :Of = "ring", :With = "♥")
	? o1.Content() #--> [ "__ ♥ __", "♥ __ ♥ __ ring", "__ ♥ __" ]

	#-- 5. REPLACING, INSIDE A GIVEN STRING, THE LAST N OCCURRENCE OF A GIVEN SUBSTRING
