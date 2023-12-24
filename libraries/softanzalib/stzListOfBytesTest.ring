
load "stzlib.ring"

# TODO: Add use cases from Qt documentation:
# https://doc.qt.io/qt-6/qbytearray.html()

/*--------------------

pron()

o1 = new stzListOfBytes("で")
? o1.ToHex() 
#--> e381a7

# TODO --> (\xE3 \x81 \xa7 in UTF-8)

proff()
#--> Executed in 0.05 second(s)

/*--------------------

pron()

o1 = new stzListOfBytes("s㊱m")

? @@( o1.Bytes() )
#--> [ "s", "�", "�", "�", "m" ]

? @@( o1.Bytecodes() )
#--> [ 115, -29, -118, -79, 109 ]

? @@( o1.BytesPerChar() )
#--> [ [ "s", [ "s" ] ], [ "㊱", [ "�", "�", "�" ] ], [ "m", [ "m" ] ] ]

? @@( o1.BytecodesPerChar() )
#--> [ [ "s", [ 115 ] ], [ "㊱", [ -29, -118, -79 ] ], [ "m", [ 109 ] ] ]

proff()
# Executed in 0.05 second(s)

/*--------------------

pron()

o1 = new stzListOfBytes("مرحبا")

? @@( o1.Bytes() )
#--> [ "�", "�", "�", "�", "�", "�", "�", "�", "�", "�" ]

? @@( o1.Bytecodes() )
#--> [ -39, -123, -40, -79, -40, -83, -40, -88, -40, -89 ]

? @@( o1.BytesPerChar() )
#--> [ [ "م", [ "�", "�" ] ], [ "ر", [ "�", "�" ] ], [ "ح", [ "�", "�" ] ], [ "ب", [ "�", "�" ] ], [ "ا", [ "�", "�" ] ] ]

? @@( o1.BytecodesPerChar() )
#--> [ [ "م", [ -39, -123 ] ], [ "ر", [ -40, -79 ] ], [ "ح", [ -40, -83 ] ], [ "ب", [ -40, -88 ] ], [ "ا", [ -40, -89 ] ] ]

proff()
# Executed in 0.05 second(s)

/*-------------------

pron()

oQByteArray = new QByteArray()
oQByteArray.append("RING")

? @@( QByteArrayToListOfUnicodes(oQByteArray) ) + NL
#--> [ 82, 73, 78, 71 ]

? @@( QByteArrayToListOfChars(oQByteArray) ) + NL
#--> [ "R", "I", "N", "G" ]

? @@( QByteArrayToListOfUnicodesPerChar(oQByteArray) )
#--> [ [ "R", [ "R" ] ], [ "I", [ "I" ] ], [ "N", [ "N" ] ], [ "G", [ "G" ] ] ]

proff()
#--> Executed in 0.06 second(s)

/*-------------------
*/
pron()

// Swapping strings using stzString

o1 = new stzString("Python")
o2 = new stzString("Ring")

? CallMethod("Content()", :On = [ :o1, :o2 ])
#--> [ "Python", "Ring" ]

o1.SwapWith(o2)

? CallMethod("Content()", :On = [ :o1, :o2 ])

// Swapping strings using stzListOfBytes

o1 = new stzListOfBytes("New")
o2 = new stzListOfBytes("Old")

? CallMethod("ToString()", :On = [ :o1, :o2 ])

o1.SwapWith(o2)

? CallMethod("ToString()", :On = [ :o1, :o2 ])

proff()

/*-------------------

o1 = new stzListOfBytes("mЖ丽")
? o1.NumberOfBytes()
? o1.BytesToUnicodes()

? o1.NumberOfBytesPerChar()

? o1.NLeftBytes(3)
? o1.NRightBytes(3)

/*-------------------

o1 = new stzListOfBytes("mЖ丽")
? o1.Range(1, 1)

/*-------------------

o1 = new QChar(65)
? hex(65) # 3067 in UTF-16

# Code point to binary
# 12391 -> binary

# encode the binary into utf8 sequence of bytes

# convert the sequence back to hex

/*-------------------

o1 = new QByteArray()
o1.append("で")
? o1.ToHex().data() # \xE3 \x81 \xa7 in UTF-8


/*-------------------

o1 = new stzString("ssdsd")
? o1.ToCharsUnicodes()

/*-------------------

o1 = new stzListOfBytes("s㊱m")

o1 {
	//? Unicode()
	? UnicodeOfByte(6)

	//? NumberOfBytes()
	//? NumberOfBytes()

	//? UnicodesOfBytes()
	//? UnicodeOfByte(3)

	//? NumberOfBytesPerChar()
	//? NumberOfBytesInCharNumber(2)
	//? NumberOfBytesInChar("㊱")

	//? BytesPerChar()

	? BytesOfCharNumer(n)
	? BytesOfChar(pcCaract)

	# ? BitsPattern() // TODO

	? NumberOfBytesPerChar()
	// --> [ :s = 1, :㊱ = 3, :m = 1 ]

}


