load "stzlib.ring"

/*--
			 
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
*/

# Splitting before a given substring with case sensitivity
o1 = new stzString("__a__A__")
? @@S( o1.SplitBeforeCS("a", :CS = FALSE) )
#--> [ "__", "a__", "A__" ]

? @@S( o1.SplitCS( :Before = "a", :CS = FALSE) )
#--> [ "__", "a__", "A__" ]


/*============ SPLITTING AT

# Splitting at a given substring with case sensitivity

o1 = new stzString("__a__A__")
? o1.SplitCS("a", :CS = FALSE)
#--> [ "__", "__", "__" ]

# Splitting at a given substring

o1 = new stzString("...♥...♥...")
? o1.Split( :At = "♥" )
#--> [ "...", "...", "..." ]

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

# Splitting at a char described by a condition

o1 = new stzString("...♥...♥...")
? o1.SplitW('@char = "♥"')
#--> [ "...", "...", "..." ]
