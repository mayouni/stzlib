# Narrative
# --------
# #narration
#
# Extracted from stzunicodedatatest.ring, block #4.
#Error (R3) : Calling Function without definition: charsandnames
#ERR Error (R3) : Calling Function without definition: charsandtheirnames

load "../../stzBase.ring"


pr()


# Getting the names of some unicode blocks along with their ranges
# in term of unicode codepoints (expressed in decimal numbers)

? ShowShortNL( UnicodeBlocksXT() ) # XT --> ..Along with their ranges
#--> [
#	[ "Basic Latin", [ 0, 127 ] ], 
#	[ "Latin-1 Supplement", [ 128, 255 ] ], 
#	[ "Latin Extended-A", [ 256, 383 ] ], 
#	"...", 
#	[ "Variation Selectors Supplement", [ 917760, 917999 ] ], 
#	[ "Supplementary Private Use Area-A", [ 983040, 1048575 ] ], 
#	[ "Supplementary Private Use Area-B", [ 1048576, 1114111 ] ]
# ]


# Searching for blocks containg the word "box"

? @@( UnicodeBlocksContaining("box") ) # or, to be precise: UnicodeBlocksNamesContaing("box")
#--> [ "Box Drawing" ]

# Getting the ranges of those boxes (only one range, since there is one block)

? @@( UnicodeBlocksContainingXT("box") )
#-->[ "Box Drawing", [9472, 9599] ]


# Transforming some of the unicode codepoints of the chars belonging to
# block "Box Drawing" to chars, so we can see them on screen()

acBoxChars = UnicodesToChars(9472:9599)
? ShowShort( acBoxChars )
#--> [ "─", "━", "│", "...", "╽", "╾", "╿" ]

# Getting the names of 5 randoms chars of them (along their unicode codepoints ~> XT),
# and we want them to be unique (the same char is not displayed twice ~> U)

? @@NL( CharsAndNames( NRandomItemsInU(5, acBoxChars) ) )
#--> [
# 	[ "┖", "BOX DRAWINGS UP HEAVY AND RIGHT LIGHT" ],
# 	[ "╸", "BOX DRAWINGS HEAVY LEFT" ],
#	[ "╏", "BOX DRAWINGS HEAVY DOUBLE DASH VERTICAL" ],
#	[ "╚", "BOX DRAWINGS DOUBLE UP AND RIGHT" ],
#	[ "┺", "BOX DRAWINGS LEFT LIGHT AND RIGHT UP HEAVY" ]
# ]

# Searching for chars containg the word "box" in their name
# (Note that we are searching directly the chars and not
# the blocks of chars as above)

# Here we take randomly 6 of them:
? ""

? NItemsIn(6, CharsContainingInTheirName("box") )
#--> [ "␣", "┌", "┞", "╬", "╼", "☐" ]

? @@NL( CharsAndTheirNames([ "␣", "┌", "┞", "╬", "╼", "☐" ]) )
#--> [
#	[ "␣", "OPEN BOX" ],
#	[ "┌", "BOX DRAWINGS LIGHT DOWN AND RIGHT" ],
#	[ "┞", "BOX DRAWINGS UP HEAVY AND RIGHT DOWN LIGHT" ],
#	[ "╬", "BOX DRAWINGS DOUBLE VERTICAL AND HORIZONTAL" ],
#	[ "╼", "BOX DRAWINGS LIGHT LEFT AND HEAVY RIGHT" ],
#	[ "☐", "BALLOT BOX" ]
# ]

ProfilerOff()

pf()
# Executed in 0.68 second(s) in Ring 1.23
# Executed in 0.76 second(s) in Ring 1.20
