load "stzlib.ring"


o1 = new stzTextStream()
o1.SetString("barababa", QIODevice_ReadOnly)

//? o1.SourceOfStream()
? o1.TextEncoding()


