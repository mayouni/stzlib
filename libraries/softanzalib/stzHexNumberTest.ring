load "stzlib.ring"

# In this sample, I'll show you the configurabiliy of SoftanzaLib.

# Hence, when you say:

? HexToDecimal("0x167A") # you get --> 5754

# But when you say:
//? HexToDecimal("x167A") # you get an error!

/* Let's analyse it:

   What : Can't create the hex number.
   Why  : The value you provided is not in correct hex form.
   Todo : Provide a hex number in a string started by "0x" and
	  containing only hex characters (from 0 to 9 and from A to F).

So! In softanza terms, the hex prefix you provided in "x167A" is not correct!
But, in reality, many people use it and it's far from beeing incorrect...

You may think that you should constraint yourself to what is possible with this library
and use only the "0x" prefix while dealing whith hex numbers...

No! Softanza won't never break your heart.
Please fellow me...

*/

# Let's see what is the actual hex number prefix used by default by Softanza
? HexPrefix() # --> "0x"

# Now, nothing prevents you from changing it to "x" instead of "0x":
SetHexPrefix("x")
? HexPrefix() # --> "x"

# Try again with the previously erronous command:
? HexToDecimal("x167A") # --> 5754

# Nice! Isn't it ;) ?

# Of course, if you opt for an absurd prefix, your are immedialy stopped:
SetHexPrefix("0x0")	# --> ERROR: Incorrect hex number prefix!

# In fact, only these three prfixes are possible: "0x", "x", and "U+".
# The last one is used for Unicode Hex numbers.

# As anything in the library, you can add more possibilities by editing
# the fellowing global variable:

? HexPrefixes() # --> [ "x", "0x", "U+" ])

# and using this function:

AddHexPrefix("OTHER")
? HexPrefixes()	# --> [ "x", "0x", "U+", "OTHER" ]

# Of course, you can remove it like this:
RemoveHexPrefix("OTHER")
? HexPrefixes() # --> [ "x", "0x", "U+" ]

# But removing one of the common hex prefixes is not allowed!
RemoveHexPrefix("x")
# --> ERROR: You can not remove basic hex prefixes: "x", "0x", and "U+"!


# NOTE: The same gymanstics apply to all other number forms supported
# by the library (decimal, binary, and octal).	# TODO


/*---------------------

? IsUnicodeHex("U+214B")

? StringRepresentsNumberInHexform("E82")
o1 = new stzHexNumber("xE82")
? o1.Content()

/*---------------------

o1 = new stzHexNumber("")
o1.FromBinary("b10011")
? o1.Content()

? o1.ToOctal()
