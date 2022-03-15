load "stzlib.ring"

o1 = new stzString("sameكلامthisمساء")
//? o1.StringPartsByOrientation()

? o1.StringParts(:ByCharCase)

/*
o1 = new stzChar("م")
? o1.Orientation()
/*
? o1.isDecimalDigit()
? o1.UnicodeCategoryNumber()
? o1.UnicodeCategory()
/*
o1 = new stzListOfBytes("ثب")
? o1.Bytes()
//? o1.Byte(64)
? o1.NthChar(2)

o1 = new stzString("﹍")
? o1.Unicode().unicode()
? o1.Unicode().isLetter()

? o1.unicode().category()

// Solve this: we provide a unicode decimal and we get the character
o2 = new QChar(65076)
? o2
