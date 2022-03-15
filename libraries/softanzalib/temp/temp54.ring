load "stzlib.ring"


# ReplaceAll(nBytesFromMainStr, nStartingAtPosition, nWithNBytes, pcFromSubstr)

o2 = new StzListOfBytes("كلsم")
? o2.NumberOfBytes()

? o2.byte(1) + o2.byte(2)

o1 = new stzListOfBytes("Riمس")
o1.Replace(2, 1, 1, "كلم") # deppricated!
? o1.Content() # Gives 'Ring'

/*
o1 = new stzListOfBytes("Rixo Rixo Rixo")
o1.ReplaceAll("xo", "ng")

? o1.Content() # Gives Ring Ring Ring
