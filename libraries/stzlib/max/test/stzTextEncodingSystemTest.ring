load "../stzmax.ring"

// Should return error
//o1 = new stzTextencoding("blabla")

// Shoud return 'UTF-8'
o1 = new stzTextEncoding("utf-8")
? o1.EncodingName()

// Test also...
//o1.setSystemEncoding()



