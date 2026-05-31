# Narrative
# --------
# pr()
#
# Extracted from stzunicodedatatest.ring, block #8.

load "../../../stzBase.ring"


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
