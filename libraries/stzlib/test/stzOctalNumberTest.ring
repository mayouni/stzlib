load "../max/stzmax.ring"

/*------ Converting from octal de decimal, binary, and hexadecimal

pron()

o1 = new stzOctalNumber("o2007")

? o1.OctalNumber()
#--> o2007

? o1.ToDecimal()
#--> 1031

? o1.ToBinary()
#--> 0b10000000111

? o1.ToHex()
#--> 0x407

proff()
# Executed in 0.05 second(s).

/*----
*/
pron()

o1 = new stzOctalNumber("o0")

// Converting back to octal from decimal, binary, and hexadecimal
o1.FromDecimal(1031)
? o1.OctalNumber()
#--> 0o2007

o1.FromHex("x407")
? o1.OctalNumber()
#--> 0o2007

o1.FromBinary("b10000000111")
? o1.OctalNumber()
#--> 0o2007

proff()
# Executed in 0.05 second(s).
