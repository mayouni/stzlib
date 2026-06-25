# Narrative
# --------
# SPLITTING AFTER
#
# Extracted from stzStringTest.ring, block #359.

load "../../stzBase.ring"


pr()

# Splitting before a given substring with case sensitivity

o1 = new stzString("__a__A__")
? @@( o1.SplitAfterCS("a", :CS = FALSE) )
#--> [ "__a", "__A", "__" ]

? @@( o1.SplitCS( :After = "a", :CS = FALSE) )
#--> [ "__a", "__A", "__" ]

? @@( o1.Split( :After = [ "a", "A" ] ) )
#--> [ "__a", "__A", "__" ]

o1 = new stzString("...♥...")
? @@( o1.Split( :AfterPosition = 4 ) )
#--> [ "...♥", "..." ]

o1 = new stzString("...♥...♥...")
? @@( o1.Split( :AfterPositions = [ 4, 8 ] ) )
#--> [ "...♥", "...♥", "..." ]

? @@( o1.Split( :AfterSection = [ 4,  8 ] ) )
#--> [ "...♥...♥", "..." ]

o1 = new stzString("...♥♥♥..♥♥..")
? @@( o1.Split( :AfterSections = [ [4, 6], [9, 10] ] ) )
#--> [ "...♥♥♥", "..♥♥", ".." ]

o1 = new stzString("...♥...♥...")
? @@( o1.SplitBeforeCharsW(' @char = "♥" ') )
#--> [ "...", "♥...", "♥..." ]

o1 = new stzString("...♥♥...♥♥...")
? @@( o1.SplitAfterSubStringsW(' @SubString = "♥♥" ') )
#--> [ "...♥♥", "...♥♥", "..." ]

pf()
# Executed in 0.55 second(s) in Ring 1.21
# Executed in 3.89 second(s) in Ring 1.18
