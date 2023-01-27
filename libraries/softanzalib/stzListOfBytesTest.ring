
load "stzlib.ring"

# TODO: Add use cases from Qt documentation:
# https://doc.qt.io/qt-6/qbytearray.html()

/*--------------------
*/
o1 = new stzListOfBytes("で")
? o1.ToHex() 
# Returns e381a7 # --> (\xE3 \x81 \xa7 in UTF-8 --> TODO)

/*--------------------

//o1 = new stzListOfBytes("مرحبا")
o1 = new stzListOfBytes("s㊱m")
? o1.Bytes()
? o1.BytesPerChar()

? o1.Bytecodes()
? o1.BytecodesPerChar()

/*-------------------

//? o1.UnicodesQ() - 0
? o1.Chars()
? o1.Unicodes()
? o1.UnicodesPerChar()

/*-------------------

? QByteArrayToListOfUnicodes(oQByteArray)
? QByteArrayToListOfChars(oQByteArray)
? QByteArrayToListOfUnicodesPerChar(oQByteArray)

/*-------------------
*
// Swapping strings using stzString

o1 = new stzString("Python")
o2 = new stzString("Ring")

? CallMethod("Content()", :On = [ :o1, :o2 ])

o1.SwapWith(o2)

? CallMethod("Content()", :On = [ :o1, :o2 ])

// Swapping strings using stzListOfBytes

o1 = new stzListOfBytes("New")
o2 = new stzListOfBytes("Old")

? CallMethod("ToString()", :On = [ :o1, :o2 ])

o1.SwapWith(o2)

? CallMethod("ToString()", :On = [ :o1, :o2 ])

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


