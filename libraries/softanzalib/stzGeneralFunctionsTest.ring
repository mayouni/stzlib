load "stzlib.ring"

/*-------------------
*/
# Softanza can do its best to infere the datatype included
# in a string, whatever form the string takes: lowercase or
# uppercase, and singular or plural!

? InfereDataTypeFromString('number')	# --> :Number
? InfereDataTypeFromString('String')	# --> :String

? InfereDataTypeFromString('NuMBer')	# --> :Number
? InfereDataTypeFromString('STRING')	# --> :String

? InfereDataTypeFromString('numbers')	# --> :Number
? InfereDataTypeFromString('STRINGS')	# --> :String

? InfereDataTypeFromString(:StzNumber)	# --> :StzNumber
? InfereDataTypeFromString(:StzNumbers)	# --> :StzNumber

? InfereDataTypeFromString(:ListOfNumbers)	# --> :ListOfNumbers
? InfereDataTypeFromString(:ListsOfNumbers)	# --> :ListOfNumbers

? InfereDataTypeFromString(:StzListOfNumbers)	# --> :StzListOfNumbers
? InfereDataTypeFromString(:StzListsOfNumbers)	# --> :StzListOfNumbers

? InfereDataTypeFromString(:ListOfStzStrings)	# --> :ListOfStzStrings
? InfereDataTypeFromString(:ListsOfStzStrings)	# --> :ListOfStzStrings

# NOTE: This function is useful for internal features of SoftanzaLib,
# inorder to enable the goal of expressive code.

# In particular, it is used in the stzList.IsListOf(pcType) method.

/*-------------------
*/
# Getting the data type of a given value

? _(5).@.DataType()		# --> :Number
? _("Ring").@.DataType()	# --> :String
? _(1:3).@.DataType()		# --> :List

obj = new Person { name = "Nehro" }
? _(obj).@.DataType()		# --> :Object

class Person name

/*-------------------

? ComputableForm(4) # --> 4
? ComputableForm("Ring") # --> "Ring"
? ComputableForm([ 1, 2, "a" ]) # --> [ 1, 2, "a" ]
// TODO: the case of objects...

/*-------------------

? "۰" = "٠"	# --> FALSE
? "۱" = "١"	# --> FALSE
? "۲" = "٢"	# --> FALSE
? "۳" = "٣"	# --> FALSE
? "۸" = "٨"	# --> FALSE		
? "۹" = "٩"	# --> FALSE
? ""
? Unicode("۱")	# --> 1777
? Unicode("١")	# --> 1633
? ""
? AreEqual([ "O", "Ο", "О" ]) # --> FALSE
? ""
? Unicodes([ "O", "Ο", "О" ]) # --> [ 79, 927, 1054 ]
? Scripts([ "O", "Ο", "О" ]) # --> [ :Latin, :Greek, :Cyrillic ]


/*
The point is that Unicode assigns unique code to Chars and
not to their visual glyfs. To give a clear example:

"O", "Ο", and "О" seam the same for us, and for the particular
font we use in our system to render them, but from a unicode
stand point, they are different.

If you try to get their unicode code points, you find them
respectively: 79, 927, and 1054.

In fact, the first is Latin "O", the second is Greek "Ο", and
the third is Cyrillic "О".
*/

/*
? "٤" = "٤"	# TRUE		01636	01636
? "٥" = "٥"	# TRUE		01637	01637
? "٦" = "٦"	# TRUE		01638	01638
? "٧" = "٧"	# TRUE		01639	01639
*/
