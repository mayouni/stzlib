load "stzlib.ring"

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
			 
         SPLITTING   |   At   |	Before | After | Between |
 --------------------+--------+--------+-------+---------+
        A Position   |   ✓   |   •    |   •   |    •    |
 --------------------+--------+--------+-------+---------+
    Many Positions   |   ✓   |   •    |   •   |    •    |
 --------------------+--------+--------+-------+---------+
       A SubString   |   ✓   |   ✓   |   •   |    •    |
 --------------------+--------+--------+-------+---------+
   Many SubStrings   |   ✓   |   •    |   •   |    •    |
 --------------------+--------+--------+-------+---------+
             Where   |   ✓   |   •    |   •   |    •    |
 --------------------+--------+--------+-------+---------+

/*============ SPLITTING BEFORE

# Splitting before a given substring with case sensitivity
o1 = new stzString("__a__A__")
? @@S( o1.SplitBeforeCS("a", :CS = FALSE) )
#--> [ "__", "a__", "A__" ]

? @@S( o1.SplitCS( :Before = "a", :CS = FALSE) )
#--> [ "__", "a__", "A__" ]

? @@S( o1.Split( :Before = [ "a", "A" ] ) )
#--> [ "__", "a__", "A__" ]

o1 = new stzString("...♥...♥...")
? @@S( o1.SplitBefore( :sPosition = 4 ) )
#--> [ "...", "♥...♥..." ]

? @@S( o1.SplitBefore( :Positions = [ 4, 8 ] ) )
#--> [ "...", "♥...", "♥..." ]

? @@S( o1.SplitBefore( :Section = [ 4,  8 ] ) )

/*============ SPLITTING AT

# Splitting at a given substring with case sensitivity

o1 = new stzString("__a__A__")
? o1.SplitCS("a", :CS = FALSE)
#--> [ "__", "__", "__" ]

# Splitting at a given substring

? @@S( o1.Split("a") )
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

# Splitting at a char described by a condition

o1 = new stzString("...♥...♥...")
? o1.SplitW('@char = "♥"')
#--> [ "...", "...", "..." ]

o1 = new stzString("...♥♥...♥♥...")
? o1.SplitW('{ @SubString = "♥♥" }')
#--> [ "...", "...", "..." ]

/*-----------------

o1 = new stzString("...ONE...TWO...ONE")
? o1.Sections([ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ])	#--> [ "ONE", "TWO", "THREE" 
? o1.AntiSections([ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ])	#--> [ "...", "...", "..." ]

/*-----------------

o1 = new stzString("...ONE...TWO...ONE")
//? @@S( o1.FindSubstringsW('{ @SubString = "ONE" or @SubString = "TWO" }') )
#--> [ 4, 10, 16 ]

? @@S( o1.FindSubstringsWXT('{ @SubString = "ONE" or @SubString = "TWO" }') )
#--> [ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ]

/*-----------------
*/
o1 = new stzString("...ONE...TWO...ONE")

? o1.SplitW('{ @SubString = "ONE" or @SubString = "TWO" }')
#--> [ "...", "...", "..." ]

? @@S( o1.SplitW('{ Q(@SubString).IsOneOfThese([ "ONE", "TWO"]) }') )
#--> [ "...", "...", "..." ]

? @@S( o1.SplitW('{ Q(@SubString).IsEither( "ONE", :Or = "TWO") }') )
#--> [ "...", "...", "..." ]


/*---------
*/
o1 = new stzString("...♥♥...♥♥...")
? @@S( o1.FindSubStringsW('{ @SubString = "♥♥" }') )
#--> [ 4, 9 ]

? @@S( o1.FindSubStringsWXT('{ @SubString = "♥♥" }') )
#--> [ [ 4, 5 ], [ 9, 10 ] ]
