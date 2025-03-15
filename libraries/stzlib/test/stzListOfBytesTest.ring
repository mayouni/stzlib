
load "../max/stzmax.ring"

#TODO // Add use cases from Qt documentation:
# https://doc.qt.io/qt-6/qbytearray.html()

/*--------------------

pr()

o1 = new stzListOfBytes("で")
? o1.ToHex() 
#--> e381a7

#TODO --> (\xE3 \x81 \xa7 in UTF-8)

pf()
#--> Executed in 0.05 second(s)

/*--------------------

pr()

o1 = new stzListOfBytes("s㊱m")

? @@( o1.Bytes() )
#--> [ "s", "�", "�", "�", "m" ]

? @@( o1.Bytecodes() )
#--> [ 115, -29, -118, -79, 109 ]

? @@( o1.BytesPerChar() )
#--> [ [ "s", [ "s" ] ], [ "㊱", [ "�", "�", "�" ] ], [ "m", [ "m" ] ] ]

? @@( o1.BytecodesPerChar() )
#--> [ [ "s", [ 115 ] ], [ "㊱", [ -29, -118, -79 ] ], [ "m", [ 109 ] ] ]

pf()
# Executed in 0.05 second(s)

/*--------------------

pr()

o1 = new stzListOfBytes("مرحبا")

? @@( o1.Bytes() )
#--> [ "�", "�", "�", "�", "�", "�", "�", "�", "�", "�" ]

? @@( o1.Bytecodes() )
#--> [ -39, -123, -40, -79, -40, -83, -40, -88, -40, -89 ]

? @@( o1.BytesPerChar() )
#--> [ [ "م", [ "�", "�" ] ], [ "ر", [ "�", "�" ] ], [ "ح", [ "�", "�" ] ], [ "ب", [ "�", "�" ] ], [ "ا", [ "�", "�" ] ] ]

? @@( o1.BytecodesPerChar() )
#--> [ [ "م", [ -39, -123 ] ], [ "ر", [ -40, -79 ] ], [ "ح", [ -40, -83 ] ], [ "ب", [ -40, -88 ] ], [ "ا", [ -40, -89 ] ] ]

pf()
# Executed in 0.05 second(s)

/*-------------------

pr()

o1 = new stzListOfBytes("RING")
? @@( o1.UnicodesPerChar() )
#--> [ [ "R", [ 82 ] ], [ "I", [ 73 ] ], [ "N", [ 78 ] ], [ "G", [ 71 ] ] ]

pf()
# Executed in 0.04 second(s)

/*-------------------

pr()

oQByteArray = new QByteArray()
oQByteArray.append("RING")

? @@( QByteArrayToListOfBytecodes(oQByteArray) ) + NL
#--> [ 82, 73, 78, 71 ]

? @@( QByteArrayToListOfChars(oQByteArray) ) + NL
#--> [ "R", "I", "N", "G" ]

? @@( QByteArrayToListOfUnicodesPerChar(oQByteArray) )
#--> [ [ "R", [ 82 ] ], [ "I", [ 73 ] ], [ "N", [ 78 ] ], [ "G", [ 71 ] ] ]

pf()
#--> Executed in 0.08 second(s)

/*-------------------

pr()

// Swapping strings using stzString

o1 = new stzString("Python")
o2 = new stzString("Ring")

? CallMethod("Content()", :On = [ :o1, :o2 ])
#--> [ "Python", "Ring" ]

o1.SwapWith(o2)

? CallMethod("Content()", :On = [ :o1, :o2 ])
#--> [ "Ring", "Python" ]

// Swapping strings using stzListOfBytes

o1 = new stzListOfBytes("New")
o2 = new stzListOfBytes("Old")

? CallMethod("ToString()", :On = [ :o1, :o2 ])
#--> [ "New", "Old" ]

o1.SwapWith(o2)

? CallMethod("ToString()", :On = [ :o1, :o2 ])
#--> [ "Old", "New" ]

pf()
# Executed in 0.06 second(s)

/*-------------------

pr()

o1 = new stzListOfBytes("mЖ丽")
? o1.NumberOfBytes()
#--> 6

? @@( o1.Bytecodes() )
#--> [ 109, -48, -106, -28, -72, -67 ]
	
? @@( o1.NumberOfBytesPerChar() )
#--> [ [ "m", 1 ], [ "Ж", 2 ], [ "丽", 3 ] ]

? o1.NLeftBytes(3) # Or 3LeftBytes()
#--> mЖ

? o1.NRightBytes(3) # Or 3RightBytes()
#--> 丽

pf()
#--> Executed in 0.03 second(s) in Ring 1.21
#--> Executed in 0.08 second(s) in Ring 1.19

/*-------------------

pr()

o1 = new stzListOfBytes("mЖ丽")
? o1.Range(1, 1)
#--> m

? o1.Range(2, 2) # Same As o1.Section(2, 3)
#--> Ж

? o1.Section(4,:End)
#--> 丽

pf()
#--> Executed in 0.04 second(s)

/*======================

pr()

? Q("abc").ContainsNo(".")
#--> TRUE

pf()
# Executed in 0.03 second(s)

/*---------------------

pr()

? Q("12500.89").RepresentsNumber()
#--> TRUE

? Q("12500").RepresentsInteger()
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.18

/*-------------------

pr()

o1 = new QChar(65)

? o1.Unicode()
#--> 65

? Q( o1.Unicode() ).ToBinary()
#--> 0b1000001

? Q( o1.Unicode() ).ToHex()
#--> 0x41

? Q( o1.Unicode() ).ToOctal()
#--> 0o101

pf()
#--> Executed in 0.03 second(s) in Ring 1.21
#--> Executed in 0.17 second(s) in Ring 1.18

/*-------------------

pr()

o1 = new QByteArray()
o1.append("で")
? o1.tohex().data()
#--> e381a7

# To get this format:  # \xE3 \x81 \xA7 (in UTF-8)
# use the ToHexUTF8() from stzListOfBytes() ~> See example below...

pf()
# Executed in almost 0 second(s).

/*-------------------
*
pr()

? str2hex("で") # A Ring function
#--> e381a7

pf()

/*-------------------

pr()

o1 = new stzListOfBytes("で")

? o1.ToHex()
#--> 0xe381a7

? o1.ToHexWithoutPrefix()
#--> e381a7

? o1.Hexcodes()
#--> [ "0xe3", "0x81", "0xa7" ]

? o1.HexcodesWithoutPrefix()
#--> [ "e3", "81", "a7" ]

? o1.ToHexUTF8()
#--> \xe3 \x81 \xa7

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.19

/*-------------------
*/
pr()

o1 = new stzString("ssdsd")

? o1.CharsU()
#--> [ "s", "d" ]

? @@( o1.Unicodes() )
#--> [ 115, 115, 100, 115, 100 ]

? @@( o1.CharsAndUnicodes() ) # Same as o1.UnicodePerChar()
#--> [ [ "s", 115 ], [ "s", 115 ], [ "d", 100 ], [ "s", 115 ], [ "d", 100 ] ]

? @@( o1.CharsAndUnicodesU() )
#--> [ [ "s", 115 ], [ "d", 100 ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.18
# Executed in 0.12 second(s) in Ring 1.17

/*-------------------

pr()

o1 = new stzListOfBytes("s㊱m")

o1 {
	? NumberOfBytes()
	#--> 5
	
	? @@( Bytecodes() )
	#--> [ 115, -29, -118, -79, 109 ]
	#TODO // Understand why some values are negative!

	? BytecodeOfByteN(5)
	#--> 109

	? NumberOfBytesInCharNumber(2)
	#--> 3

	? NumberOfBytesInChar("㊱")
	#--> 3

	? @@( BytesPerChar() )
	#--> [ [ "s", [ "s" ] ], [ "㊱", [ "�", "�", "�" ] ], [ "m", [ "m" ] ] ]

	? @@( BytesOfCharNumber(2) )
	#--> [ "�", "�", "�" ]

	? @@( BytesOfChar("㊱") )
	#--> [ "�", "�", "�" ]

	# ? BitsPattern() // TODO

	? @@( NumberOfBytesPerChar() )
	#--> [ :s = 1, :㊱ = 3, :m = 1 ]

}

pf()
# Executed in 0.05 second(s) on Ring 1.21
# Executed in 0.12 second(s) on Ring 1.18
