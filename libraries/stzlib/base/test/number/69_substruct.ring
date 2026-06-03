# Narrative
# --------
# /////
#
# Extracted from stznumbertest.ring, block #69.

load "../../stzBase.ring"

pr()

o1 = new stzNumber(24)
? o1.SubStructQ(12).Content()
? o1.AddManyXT([ "4.65775", "3", "2" ], :ReturnIntermediateResults = TRUE)
//? o1.SubStructManyXT([ "12", "10.6532", "3" ], :ReturnIntermediateResults = TRUE )
//? o1.Content()
/*
? o1.ToBinaryFormWithoutPrefix()
? o1.ToSignedBinaryFormWithoutPrefix()
//? o1.ToSignedBinaryForm()
/*
//o1 = new stzNumber("-12_349") #ERRor with ? o1.HasFractionalPart()
o1 = new stzNumber("-12_349.23")

//? o1.Number()
//? o1.IntegerPartValue()
//? o1.FractionalPart()
//? o1.FractionalPartToBinaryFormWithoutZeroDot()
? o1.IntegerPartToBinaryForm()
? o1.ToBinaryForm()
/*
? o1.IntegerPartValue()
? o1.IntegerPartWithoutSign()
? o1.FractionalPart()
? o1.FractionalPartWithoutZeroDot()

/*
//o1 = new stzNumber("o30467")
//o1 = new stzNumber("xE019")
o1 = new stzNumber("b100110011")
o1 = new stzNumber("369900990099")
? o1.RemoveSignQ().Content() # or o1.SignRemoved()
? o1.NumberOfDigitsInIntegerPart()
? o1.Round()

pf()
