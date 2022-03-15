load "stzlib.ring"

str = "hema"

o1 = new stzListOfBytes("d")
? o1.Content()


o1 = new stzListOfBytes("teebah")
? o1.Content()
? o1.ToBase64()


/*
o1 = new QByteArray() { append("{a fishy string?}") }
// Returns a URI/URL-style percent-encoded copy of this list of bytes
o2 = new QByteArray() { append("{}") }
o3 = new QByteArray() { append("s") }
//o6 = new QByteArray()
 ? o1.toPercentEncoding(o2, o3, ascii("%")).constdata()
// toPercentEncoding( baExcludedFromEncoding, baIncludedInEncoding, cCarac)

/*
Returns a URI/URL-style percent-encoded copy of this byte array.
The percent parameter allows you to override the default '%' character for another.

By default, this function will encode all characters that are not one of the following:

ALPHA ("a" to "z" and "A" to "Z") / DIGIT (0 to 9) / "-" / "." / "_" / "~"

To prevent characters from being encoded pass them to exclude. To force characters to be encoded pass them to include. The percent character is always encoded.
*/
