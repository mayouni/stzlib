load "stzlib.ring"

? StzUnicodeDataQ().CharUnicodeByName("CHECK MARK")

/*-----------------

? StzCharQ(610).Content() # --> ɢ
? StzCharQ("0x0262").Content()	# --> ɢ
? StzCharQ("LATIN LETTER SMALL CAPITAL G").Content() # # --> ɢ

? StzCharQ("0x2601").Content()	# --> ☁
? StzCharQ(12500).Content() # --> ピ

/*-----------------

StzUnicodeDataQ() {

	? FindCharName("CLOUD")	+ NL # --> 506499

	? SearchCharName("CLOUD") # -->
	# [ 506499, 514585, 514690, 1751988, 1752036, 1752084, 1752125, 1752166, 1752207, 1752253 ]

	// ? CharsContaining("CLOUD")
	// ? CharsNamesContaining("LATIN")
	
	? ContainsCharName("LATIN LETTER SMALL CAPITAL G") #--> TRUE
	
	? CharByName("LATIN LETTER SMALL CAPITAL G") # --> ɢ
	? CharByName("CLOUD") # --> ☁

	? CharHexCodeByName("LATIN LETTER SMALL CAPITAL G") # --> 0x0262
	? CharHexCodeByName("CLOUD") # --> 0x2601

	? CharByHexCode("0x0262") # --> ɢ
	? CharByHexCode("0x2601") # --> ☁

	? CharByDecimalCode(12500) # --> ピ

	? CharHexCodeByName("LATIN LETTER SMALL CAPITAL G") # --> 0x0262
	? CharUnicodeByName("LATIN LETTER SMALL CAPITAL G") # --> 610

	? CharNameByHexCode("0x0262") # LATIN LETTER SMALL CAPITAL G
	? CharNameByUnicode(12500) # --> KATAKANA LETTER PI
	? CharNameByHexCode("0x0061") # --> LATIN SMALL LETTER A
	
}

