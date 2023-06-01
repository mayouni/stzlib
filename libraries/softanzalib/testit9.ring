load "stzlib.ring"


/*-----------
			 
         SPLITTING   |   At   |	Before | After | Between |
 --------------------+--------+--------+-------+---------+
        A Position   |   ✓   |   ✓   |   ✓   |    •    |
 --------------------+--------+--------+-------+---------+
    Many Positions   |   ✓   |   ✓   |   ✓   |    •    |
 --------------------+--------+--------+-------+---------+
       A SubString   |   ✓   |   ✓   |   ✓   |    •    |
 --------------------+--------+--------+-------+---------+
   Many SubStrings   |   ✓   |   ✓   |   ✓   |    •    |
 --------------------+--------+------- +-------+---------+
             Where   |   ✓   |   ✓   |   ✓   |    •    |
 --------------------+--------+--------+-------+---------+



/*============ SPLITTING BEFORE

# Splitting before a given substring with case sensitivity

o1 = new stzString("__a__A__")
? @@S( o1.SplitBeforeCS("a", :CS = FALSE) )
#--> [ "__", "a__", "A__" ]

? @@S( o1.SplitCS( :Before = "a", :CS = FALSE) )
#--> [ "__", "a__", "A__" ]

? @@S( o1.Split( :Before = [ "a", "A" ] ) ) + NL
#--> [ "__", "a__", "A__" ]

o1 = new stzString("...♥...♥...")
? @@S( o1.Split( :BeforePosition = 4 ) )
#--> [ "...", "♥...♥..." ]

? @@S( o1.Split( :BeforePositions = [ 4, 8 ] ) )
#--> [ "...", "♥...", "♥..." ]

? @@S( o1.Split( :BeforeSection = [ 4,  8 ] ) )
#--> [ "...", "♥...♥..." ]

o1 = new stzString("...♥♥♥..♥♥..")
? @@S( o1.Split( :BeforeSections = [ [4, 6], [9, 10] ] ) )
#--> [ "...", "♥♥♥..", "♥♥.." ]

o1 = new stzString("...♥...♥...")
? @@S( o1.SplitBeforeW(' @char = "♥" ') )
#--> [ "...", "♥...", "♥..." ]

o1 = new stzString("...♥♥...♥♥...")
? @@S( o1.SplitBeforeW(' @SubString = "♥♥" ') )
#--> [ "...", "♥♥...", "♥♥..." ]

/*============ SPLITTING AT
*/
pron()

# Splitting at a given substring with case sensitivity
/*
o1 = new stzString("__a__A__")
? o1.SplitCS("a", :CS = FALSE)
#--> [ "__", "__", "__" ]

# Splitting at a given substring (without case sensitivity)

? @@( o1.Split("a") )
#--> [ "__", "__A__" ]

# Splitting at a given position

o1 = new stzString("...♥...")
? o1.Split( :At = 4 )
#--> [ "...", "..." ]

# Splitting at many positions

o1 = new stzString("...♥...♥...")
? o1.Split( :At = [ 4, 8 ] )
#--> [ "...", "...", "..." ]

# Splitting at many substrings

o1 = new stzString("...♥...★...")
? o1.Split( :At = [ "♥", "★" ] )
#--> [ "...", "...", "..." ]

# Splitting at a given section

o1 = new stzString("...♥♥♥...")
? o1.SplitAt( :Section = [ 4, 6 ] )
#--> [ "...", "..." ]

? @@S( o1.Split( :AtSection = [ 4, 6 ] ) )
#--> [ "...", "..." ]

# Splitting at many sections

o1 = new stzString("...♥♥♥...♥♥...")
? o1.Split( :AtSections = [ [ 4, 6 ], [10, 11] ] )
#--> [ "...", "...", "..."]
*/
# Splitting at a char described by a condition

o1 = new stzString("...♥...♥...")
? o1.SplitW('@char = "♥"')
#--> [ "...", "...", "..." ]
/*
# Splitting at a substring described by a condition

o1 = new stzString("...♥♥...♥♥...")
? o1.SplitW('{ @SubString = "♥♥" }')
#--> [ "...", "...", "..." ]

o1 = new stzString("...ONE...TWO...ONE")
? o1.SplitW('{ @SubString = "ONE" or @SubString = "TWO" }')
#--> [ "...", "...", "..." ]

? @@S( o1.SplitW('{ Q(@SubString).IsOneOfThese([ "ONE", "TWO"]) }') )
#--> [ "...", "...", "..." ]

? @@S( o1.SplitW('{ Q(@SubString).IsEither( "ONE", :Or = "TWO") }') )
#--> [ "...", "...", "..." ]
*/
proff()

/*============ SPLITTING AFTER

# Splitting before a given substring with case sensitivity

o1 = new stzString("__a__A__")
? @@S( o1.SplitAfterCS("a", :CS = FALSE) )
#--> [ "__a", "__A", "__" ]

? @@S( o1.SplitCS( :After = "a", :CS = FALSE) )
#--> [ "__a", "__A", "__" ]

? @@S( o1.Split( :After = [ "a", "A" ] ) )
#--> [ "__a", "__A", "__" ]

o1 = new stzString("...♥...")
? @@S( o1.Split( :AfterPosition = 4 ) )
#--> [ "...♥", "..." ]

o1 = new stzString("...♥...♥...")
? @@S( o1.Split( :AfterPositions = [ 4, 8 ] ) )
#--> [ "...♥", "...♥", "..." ]

? @@S( o1.Split( :AfterSection = [ 4,  8 ] ) )
#--> [ "...♥...♥", "..." ]

o1 = new stzString("...♥♥♥..♥♥..")
? @@S( o1.Split( :AfterSections = [ [4, 6], [9, 10] ] ) )
#--> [ "...♥♥♥", "..♥♥", ".." ]

o1 = new stzString("...♥...♥...")
? @@S( o1.SplitAfterW(' @char = "♥" ') )
#--> [ "...♥", "...♥", "..." ]

o1 = new stzString("...♥♥...♥♥...")
? @@S( o1.SplitAfterW(' @SubString = "♥♥" ') )
#--> [ "...♥", "♥...♥", "♥..." ]

/*==================

o1 = new stzString("...ONE...TWO...ONE")
? o1.Sections([ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ])	#--> [ "ONE", "TWO", "THREE" 
? o1.AntiSections([ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ])	#--> [ "...", "...", "..." ]

/*-----------------
*/
o1 = new stzString("...ONE...TWO...ONE")
//? @@S( o1.FindSubstringsW('{ @SubString = "ONE" or @SubString = "TWO" }') )
#--> [ 4, 10, 16 ]

? @@S( o1.FindSubstringsAsSectionsW('{ @SubString = "ONE" or @SubString = "TWO" }') )
#--> [ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ]

/*-----------------

o1 = new stzString("...♥♥...♥♥...")
? @@S( o1.FindSubStringsW('{ @SubString = "♥♥" }') )
#--> [ 4, 9 ]

? @@S( o1.FindSubStringsAsSectionsW('{ @SubString = "♥♥" }') )
#--> [ [ 4, 5 ], [ 9, 10 ] ]

#---
/*
o1 = new stzString("..ONE..TWO..ONE..")
? o1.NumberOfSubStrings() #--> 153
? o1.NumberOfUniqueSubStrings()	#--> 120

#---

o1 = new stzString("ABA")
? @@S( o1.SubStrings() )
#--> [ "A", "AB", "B", "ABA", "A", "BA" ]

? @@S( o1.UniqueSubStrings() )
#--> [ "A", "AB", "B", "ABA", "BA" ]

? @@S( o1.SubStringsAndTheirPositions() )
#--> [
#	[ "A", 	 [ 1, 3 ] ],
#	[ "AB",  [ 1 ] ],
#	[ "B", 	 [ 2 ] ],
#	[ "ABA", [ 1 ] ],
#	[ "BA",  [ 2 ] ]
# ]

? @@S( o1.SubStringsXT() )
#--> [
#	"A"	= [ [ 1, 1 ], [ 3, 3 ] ],
#	"AB"	= [ [ 1, 2 ] ],
#	"B"	= [ [ 2, 2 ] ],
#	"ABA"	= [ [ 1, 3 ] ],
#	"BA"	= [ [ 2, 3 ] ]
# ]

#-------
/*
? Q("one").IsEitherCS("ONE", :Or = "TWO", :CS = FALSE)
#--> TRUE

#-------
/*
o1 = new stzString("<<word>> and __word__")
? @@S( o1.Bounds( :Of = "word", :UpToNChars = 2 ) )
#--> [ [ "<<", ">>" ], [ "__", "__" ] ]
		
#-- EXAMPLE 2
		
o1 = new stzString("<<word>> and __word__")
? @@S( o1.Bounds( :Of = "word", :UpToNChars = [ 2, 2 ]  ) )
#--> [ [ "<<", ">>" ], [ "__", "__" ] ]
		
#-- EXAMPLE 3
	
o1 = new stzString("<<word>>> and  _word__")
? @@S( o1.Bounds( :Of = "word", :UpToNChars = [ [ 2, 3 ], [ 1, 2 ] ]  ) )
#--> [ [ "<<", ">>>" ], [ "_", "__" ] ]

/*--------------

? Q(:IsBoundedBy = ".").IsISBoundedByNamedParam()
#--> TRUE

? Q(".♥.").SubStringIsBoundedBy("♥", ".")
#--> TRUE

? Q(".♥.").SubString("♥", :IsBoundedBy = ".")

/*--------------
