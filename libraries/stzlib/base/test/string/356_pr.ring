# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #356.

load "../../stzBase.ring"


# Splitting before a given substring with case sensitivity

o1 = new stzString("__a__A__")

? @@( o1.SplitBeforeCS("a", :CS = FALSE) )
#--> [ "__", "a__", "A__" ]

? @@( o1.SplitCS( :Before = "a", :CS = FALSE) )
#--> [ "__", "a__", "A__" ]

? @@( o1.Split( :Before = [ "a", "A" ] ) ) + NL
#--> [ "__", "a__", "A__" ]

#---

o1 = new stzString("...♥...♥...")
? @@( o1.Split( :BeforePosition = 4 ) )
#--> [ "...", "♥...♥..." ]

? @@( o1.Split( :BeforePositions = [ 4, 8 ] ) )
#--> [ "...", "♥...", "♥..." ]

? @@( o1.Split( :BeforeSection = [ 4,  8 ] ) ) + NL
#--> [ "...", "♥...♥..." ]

#---

o1 = new stzString("...♥♥♥..♥♥..")
? @@( o1.Split( :BeforeSections = [ [4, 6], [9, 10] ] ) )
#--> [ "...", "♥♥♥..", "♥♥.." ]

o1 = new stzString("...♥...♥...")
? @@( o1.SplitBeforeCharsWXT(' @char = "♥" ') )
#--> [ "...", "♥...", "♥..." ]

o1 = new stzString("...♥♥...♥♥...")
? @@( o1.SplitBeforeSubStringsWXT(' @SubString = "♥♥" ') )
#--> [ "...", "♥♥...", "♥♥..." ]


pf()
# Executed in 0.50 second(s) in Ring 1.21
