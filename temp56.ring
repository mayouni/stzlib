load "stzlib.ring"

o1 = new stzBinaryNumber("0b111001")
? o1.ToDecimalForm()
? o1 & 12


/*
decimals(4)
o1 = new stzBinaryNumber("11.1011")
? o1.IntegerPartToDecimal()
? o1.FractionalPartToDecimal()
? o1.ToDecimal()
