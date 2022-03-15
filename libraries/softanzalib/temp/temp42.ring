load "stzlib.ring"

o1 = new stzFile("barra.txt")
? o1.Size()
? o1.OpeningMode()
//o1.ChangeOpeningModeTo(:WriteOnlyAtEnd)
? o1.ReadNChars(6)
? o1.ReadNChars(1)
? o1.ReadNChars(6)
