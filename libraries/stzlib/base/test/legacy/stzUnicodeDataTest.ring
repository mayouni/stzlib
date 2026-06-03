load "../stzbase.ring"

/*----
*/
pr()

# Getting a char by its unicode codepoint
? StzChar(65014) #--> ﷶ
? StzChar(65013) #--> ﷵ

# Taking the way back and getting the unicode
# codepoint of a given char
? Unicode("ﷶ") #--> 65014
? Unicode("ﷵ") #--> 65013


pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.19

/*----

pr()

? MaxUnicode()
#--> 1_114_112

? NumberOfUnicodeChars()
#--> 149_186

? NumberOfLinesInUnicodeDataFile() + NL
#--> 34_931

pf()

/*---

pr()

StzUnicodeDataQ() {

	? ShowShort( UnicodesOfCharsContaining("arabic") )
	#--> [ 1536, 1537, 1538, "...", 126651, 126704, 126705 ]

	? ShowShort( CharsContaining("arabic") )
	#--> [ "؀", "؁", "؂", "...", "", "", "" ]
}

pf()
# Executed in 0.76 second(s)

/*------ #narration

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
# Executed in 0.68 second(s) in Ring 1.23
# Executed in 0.76 second(s) in Ring 1.20

/*-----------------

pr()

? ShowShortXTNL( UnicodeBlocks(), 5 )

#-->
'
[
	"Basic Latin", 
	"Latin-1 Supplement", 
	"Latin Extended-A", 
	"Latin Extended-B", 
	"IPA Extensions", 
	"...", 
	"CJK Unified Ideographs Extension G", 
	"Tags", 
	"Variation Selectors Supplement", 
	"Supplementary Private Use Area-A", 
	"Supplementary Private Use Area-B"
]
'

? ShowShortNL( UnicodeBlocksAndTheirRanges() )
#-->
'
[
	[ "Basic Latin", [ 0, 127 ] ], 
	[ "Latin-1 Supplement", [ 128, 255 ] ], 
	[ "Latin Extended-A", [ 256, 383 ] ], 
	"...", 
	[ "Variation Selectors Supplement", [ 917760, 917999 ] ], 
	[ "Supplementary Private Use Area-A", [ 983040, 1048575 ] ], 
	[ "Supplementary Private Use Area-B", [ 1048576, 1114111 ] ]
]
'

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.20

/*-----------------

pr()

? StzUnicodeDataQ().CharUnicodeByName("CHECK MARK")
#--> 10003

pf()
# Executed in 0.06 second(s) in Ring 1.23
#--> Executed in 0.33 second(s) in Ring 1.20

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
# Executed in 0.07 second(s) in Ring 1.23
# Executed in 0.38 second(s) in Ring 1.20

/*-----------------

pr()

StzUnicodeDataQ() {

	? FindCharByName("CLOUD") + NL
	#--> 506499

	? SearchCharByName("CLOUD") #ERROR : logical error! See next...
	#--> [ 506499, 514585, 514690, 1751988, 1752036, 1752084, 1752125, 1752166, 1752207, 1752253 ]

	? @@( First3(CharsContaining("CLOUD")) )
	#--> [ "☁", "⛅", "⛈" ]

	//? @@( First3(CharsNamesContaining("CLOUD")) ) #ERROR: Idem
	#--> ERR: Can't proceed! The name of this char () does not exist in the local unicode database.

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
# Executed in 0.53 second(s) in Ring 1.23
