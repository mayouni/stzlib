load "../stzbase.ring"

pr()

# Getting a char by its unicode codepoint
? StzChar(65014) #--> ﷶ
? StzChar(65013) #--> ﷵ

# Taking the way back and getting the unicode
# codepoint of a given char
? Unicode("ﷶ") #--> 65014
? Unicode("ﷵ") #--> 65013

# Executed in 0.06 second(s)

pf()
# Executed in 0.02 second(s) in Ring 1.21

/*----

pr()

? MaxUnicode()
#--> 1_114_112

? NumberOfUnicodeChars()
#--> 149_186

? NumberOfLinesInUnicodeDataFile()
#--> 34_626

StzUnicodeDataQ() {

	? UnicodesOfCharsContaining("arabic")
	# 0.22 seconds

	? CharsContaining("arabic")
	# 0.40 seconds

}

pf()
# Executed in 0.58 second(s)

/*------ #narration

*/
pr()

# Setting the Some() function to return 3 items (by default it returns 5)

SetSomeTo(3)

# Getting the names of some unicode blocks along with their ranges
# in term of unicode codepoints (expressed in decimal numbers)

? Some( UnicodeBlocksXT() ) # XT --> ..Along with their ranges
#--> [
#	[ "Osage", [66736, 66815] ],
#	[ "Manichaean", [68288, 68351 ] ],
# 	[ "Dives Akuru", [72272, 72367] ]
# ]

# Searching for blocks containg the word "box"

? UnicodeBlocksContaining("box") # or, to be precise: UnicodeBlocksNamesContaing("box")
#--> [ "Box Drawing" ]

# Getting the ranges of those boxes (only one range, since there is one block)

? UnicodeBlocksContainingXT("box")
#-->[ "Box Drawing", [9472, 9599] ]

# Setting the default number of items returned by some() function to 9

SetSomeTo(9)

# Transforming some of the unicode codepoints of the chars belonging to
# block "Box Drawing" to chars, so we can see them on screen()

? Some( UnicodesToChars(9472:9599) )
#--> [ "┆", "┒", "┣", "┮", "╇", "╚", "╝", "╻", "╿", "┖" ]

# Getting the names of 5 randoms chars of them (along their unicode codepoints ~> XT),
# and we want them to be unique (the same char is not displayed twice ~> U)

? CharsAndNames( NRandomItemsInU(5, [ "┆", "┒", "┣", "┮", "╇", "╚", "╝", "╻", "╿", "┖" ]) )
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

# Here we take randsomly 6 of them:

? NItemsIn(6, CharsContainingInTheirName("box") )
#--> [ "␣", "┌", "┞", "╬", "╼", "☐" ]

? CharsAndTheirNames([ "␣", "┌", "┞", "╬", "╼", "☐" ])
#--> [
#	[ "␣", "OPEN BOX" ],
#	[ "┌", "BOX DRAWINGS LIGHT DOWN AND RIGHT" ],
#	[ "┞", "BOX DRAWINGS UP HEAVY AND RIGHT DOWN LIGHT" ],
#	[ "╬", "BOX DRAWINGS DOUBLE VERTICAL AND HORIZONTAL" ],
#	[ "╼", "BOX DRAWINGS LIGHT LEFT AND HEAVY RIGHT" ],
#	[ "☐", "BALLOT BOX" ]
# ]

ProfilerOff()
# Executed in 0.76 second(s)

/*-----------------

pr()

? Some( UnicodeBlocks() ) # By default, Some() function returns 10 items

#--> [ "Basic Latin", "Block Elements", "Tai Viet",
# 	"Arabic Presentation Forms-A", "CJK Compatibility Forms",
# 	"Ancient Greek Numbers", "Bhaiksuki", "Adlam",
# 	"Mahjong Tiles", "Enclosed Alphanumeric Supplement"
# ]

# Let's change the default number of items returned by Some() function:
SetDefaultSome(3)

? Some( UnicodeBlocksAndTheirRanges() )
#--> [
# 	[ "Combining Diacritical Marks", [768, 879] ],
# 	[ "Mro", [92704, 92767] ],
# 	[ "Adlam", [123904, 123951] ]
# ]

pf()
# Executed in 0.04 second(s)

/*-----------------

pr()

? StzUnicodeDataQ().CharUnicodeByName("CHECK MARK")

pf()
#--> Executed in 0.33 second(s)

/*-----------------

pr()

? StzCharQ(610).Content()
#--> ɢ

? StzCharQ("0x0262").Content()
#--> ɢ

? StzCharQ("LATIN LETTER SMALL CAPITAL G").Content()
# #--> ɢ

? StzCharQ("0x2601").Content()
#--> ☁

? StzCharQ(12500).Content()
#--> ピ

pf()
# Executed in 0.38 second(s)

/*-----------------
*/
pr()

StzUnicodeDataQ() {

	? FindCharByName("CLOUD") + NL
	#--> 506499

	? SearchCharByName("CLOUD") #ERROR : logical error! See next...
	#--> [ 506499, 514585, 514690, 1751988, 1752036, 1752084, 1752125, 1752166, 1752207, 1752253 ]

	? @@( CharsContaining("CLOUD") ) #ERROR: Error bur related to SearCharByName()
	#--> [ "몄", "?", "?", "뮵", "믥", "박", "밾", "뱧", "벐", "벾" ]

	? @@( CharsNamesContaining("CLOUD") ) #ERROR: Idem
	#--> [ "LATIN CAPITAL LETTER N", "LATIN CAPITAL LETTER U", "LATIN CAPITAL LETTER L", "LATIN CAPITAL LETTER L" ]

	? @@( CharsNamesContaining("LATIN") )
	#--> [ "LATIN CAPITAL LETTER N", "LATIN CAPITAL LETTER U", "LATIN CAPITAL LETTER L", "LATIN CAPITAL LETTER L" ]
	
	#--

	? ContainsCharName("LATIN LETTER SMALL CAPITAL G")
	#--> TRUE

	? CharByName("LATIN LETTER SMALL CAPITAL G")
	#--> ɢ

	? CharByName("CLOUD")
	#--> ☁

	? CharHexCodeByName("LATIN LETTER SMALL CAPITAL G")
	#--> 0x0262

	? CharHexCodeByName("CLOUD")
	#--> 0x2601

	? CharByHexCode("0x0262")
	#--> ɢ

	? CharByHexCode("0x2601")
	#--> ☁

	? CharByDecimalCode(12500)
	#--> ピ

	? CharHexCodeByName("LATIN LETTER SMALL CAPITAL G")
	#--> 0x0262

	? CharUnicodeByName("LATIN LETTER SMALL CAPITAL G")
	#--> 610

	? CharNameByHexCode("0x0262")
	#--> LATIN LETTER SMALL CAPITAL G

	? CharNameByUnicode(12500)
	#--> KATAKANA LETTER PI

	? CharNameByHexCode("0x0061")
	#--> LATIN SMALL LETTER A
	
}

pf()

