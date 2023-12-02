load "stzlib.ring"

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

