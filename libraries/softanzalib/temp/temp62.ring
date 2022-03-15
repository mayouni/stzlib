load "stzlib.ring"

? Unicode("０") # Gives 65296
o1 = new stzChar(65296)
? o1.Content()
? ""
? Unicode("")
o1 = new stzChar(16)
? o1.Content()
? ""
? Unicode("٠")
o1 = new stzChar(1632)
? o1.Content()
? ""
? Unicode("و")
o1 = new stzChar(1608)
? o1.Content()
