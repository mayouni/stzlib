# Narrative
# --------
# SPLITTING AT
#
# Extracted from stzStringTest.ring, block #358.

load "../../stzBase.ring"


pr()

# Splitting at a given substring with case sensitivity

o1 = new stzString("__a__A__")

? o1.SplitCS("a", :CS = FALSE)
#--> [ "__", "__", "__" ]

# Splitting at a given substring (without case sensitivity)

? o1.Split("a")
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

? o1.Split( :AtSection = [ 4, 6 ] )
#--> [ "...", "..." ]

# Splitting at many sections

o1 = new stzString("...♥♥♥...♥♥...")
? o1.Split( :AtSections = [ [ 4, 6 ], [10, 11] ] )
#--> [ "...", "...", "..."]

# Splitting at a char described by a condition

o1 = new stzString("...♥...♥...")
? o1.SplitAtCharsW('@char = "♥"')
#--> [ "...", "...", "..." ]

# Splitting at a substring described by a condition

o1 = new stzString("...♥♥...♥♥...")
? o1.SplitAtSubStringsW('{ @SubString = "♥♥" }')
#--> [ "...", "...", "..." ]

o1 = new stzString("...ONE...TWO...ONE")
? o1.SplitAtSubStringsW('{ @SubString = "ONE" or @SubString = "TWO" }')
#--> [ "...", "...", "..." ]

# Complex predicates -> the WF (anonymous-function) form:
? o1.SplitAtSubStringsWF( func s { return Q(s).IsOneOfThese([ "ONE", "TWO" ]) } )
#--> [ "...", "...", "..." ]

? o1.SplitAtSubStringsWF( func s { return Q(s).IsEither( "ONE", :Or = "TWO") } )
#--> [ "...", "...", "..." ]

pf()
# Executed in 2.60 second(s) in Ring 1.21
