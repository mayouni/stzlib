load "stzlib.ring"

o1 = new QByteArray() {
	// Adds data at the end
	append("Здравствуй") # string is tranformed to bytes
	? data()
/*
	// Ads n bytes from the str at the beginning
	prepend("ABC",2)

	// Gives the object pointer
	? objectpointer()

	// Reads the byte array data
	? data()	# Здравствуй

	// Same as dat() but faster in read-only access
	? constdata()

	// Gives the number of bytes in the array
	? size()	# 20

	// Accesses a byte in the array
	? at(19)	# -71

	// Deletes the QButeArray content and object pointer
	//delete()

	// Returns true if the byte array has size 0; otherwise returns false
	? isempty()

	// Clears the contents of the byte array and makes it null
	//clear()

	// Returns true if this byte array is null; otherwise returns false.
	? isnull()

	? startswith("Здр")
	? endswith("вуй")

	// Removes n bytes from the end
	chop(4)

	// Finds the number of occurrennces of "в" in the array
	? count("в")

	// Finds a substr
	? contains("рав")

	// Ends with a substr
	? endswith("ств")

	// Finds first substr starting from byte number... (return -1 if nothting)
	? indexof("в",9)

	// inverse of indexof()
	? lastIndexof("в",13)

	// Inserts n bytes of a substr in the array
	str = "HIV"
	InsertBefore(10, str, 2) # isnerts only 2 bytes of "HIV" before byte number 10	

	// Sets each byte in the byte array to character ch.
	// If size is different from -1 (the default), the byte array is
	// resized to size size beforehand.
	fill(ascii("m"),3)

	// Returns the n left bytes in a new byte array
	? left(4).data()

	// Returns the n right bytes in a new byte array
	? right(4).data()

	// LeftJustified(size, caract, btrancate)
	? leftJustified(30, ascii("x"), TRUE).data()

	// RightJustified(size, caract, btrancate)
	? RightJustified(30, ascii("x"), TRUE).data()

	// Removes 6 bytes starting from position 2
	remove(2,6)

	// Returns a binary array of 8 bytes strating from position 4
	? mid(4,8).data()

	// Repats the binary string n times
	? repeated(3).data()

	// remove(nstart, numbytes)
	remove(0,2)

	// ERROR --> !!
	//replace("ств",0,"x",0)

	// resises the binary array
	resize(10)

	// reservves n bytes of memory for the array
	reserve(20) # use it if you know the sise in advance -> better performance

	// sets the binary array to the printed value of the number 63 in base 16
	// base can be any number from 2 to 36
	setNum(63,16)


	append("  lots   of whitespaces ")
	? data()
	// Returns a byte array that has whitespace removed from the start and the end,
	// and which has each sequence of internal whitespace replaced with a single
	// space.
	? simplified().data()	# "lots of whitespace"


	//Releases any memory not required to store the array's data.
	squeeze()

	// Swaps this binary string wuth an other
	o2 = new QByteArray()
	o2.append("سلام")
	swap(o2)

	// Returns a Base64 copy of the binary array
	? toBase64().data()

	// Decoding Base64 QByteArray
	o3 = new QByteArray()
	o3.append("PHA+SGVsbG8/PC9wPg==")
	? fromBase64(o3).data()

	append("{a fishy string?}")
	// Returns a URI/URL-style percent-encoded copy of this byte array
	o4 = new QByteArray() { append("{}") }
	o5 = new QByteArray() { append("s") }
	//o6 = new QByteArray()
	 ? toPercentEncoding(o4,o5,ascii("%")).constdata()
	// toPercentEncoding( baExcludedFromEncoding, baIncludedInEncoding, cCarac)

	// Decodes a URI/URL-style
	o8 = new QByteArray()
	o8.append("Ring%20is%20great%21")
	? fromPercentEncoding(o8,ascii("%")).data()

	// Returns a hex encoded copy of the byte array
	// The hex encoding uses the numbers 0-9 and the letters a-f
	? toHex().data()
	? data()

	// Returns a decoded copy of the hex string provided
	o7 = new QByteArray()
	o7.append("52696e6720697320677265617421")
	? fromHex(o7).data()


	// Returns a lowercase copy of the byte array
	// The bytearray is interpreted as a Latin-1 encoded string.
	append("ABC")
	? toLower().data()

	append("abc")
	// Returns a uppercase copy of the byte array
	? toUPPER().data()

	append("  a lot of spaces     ")	
	// Returns a byte array that has whitespace removed from the start and the end
	? trimmed().data()

	// Truncates the byte array at index position pos()
	// If pos is beyond the end of the array, nothing happens
	truncate(8)
*/

	? data()
}
