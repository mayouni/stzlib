load "stzlib.ring"

/*------

ProfilerOn()

SetSomeTo(3)

? Some( UnicodeBlocksXT() ) # XT --> ..Along with their ranges
#--> [
#	[ "Osage", [66736, 66815] ],
#	[ "Manichaean", [68288, 68351 ] ],
# 	[ "Dives Akuru", [72272, 72367] ]
# ]

? UnicodeBlocksContaining("box")
#--> [ "Box Drawing" ]

? UnicodeBlocksContainingXT("box")
#-->[ "Box Drawing", [9472, 9599] ]

SetSomeTo(9)

? Some( UnicodesToChars(9472:9599) )
#--> [ "┅", "┊", "┧", "┯", "╇", "╉", "╢", "╤", "╪" ]

ProfilerOff()
# Executed in 0.07 second(s)

/*-----------------

pron()

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

proff()
# Executed in 0.04 second(s)

/*-----------------

pron()

? StzUnicodeDataQ().CharUnicodeByName("CHECK MARK")

proff()
#--> Executed in 0.33 second(s)

/*-----------------

pron()

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

proff()
# Executed in 0.38 second(s)

/*-----------------
*/
pron()

StzUnicodeDataQ() {

	? FindCharByName("CLOUD") + NL
	#--> 506499

	? SearchCharByName("CLOUD") # ERROR : logical error! See next...
	#--> [ 506499, 514585, 514690, 1751988, 1752036, 1752084, 1752125, 1752166, 1752207, 1752253 ]

	? @@( CharsContaining("CLOUD") ) # ERROR: Error bur related to SearCharByName()
	#--> [ "몄", "?", "?", "뮵", "믥", "박", "밾", "뱧", "벐", "벾" ]

	? @@( CharsNamesContaining("CLOUD") ) # ERROR: Idem
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

proff()

